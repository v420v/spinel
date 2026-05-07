# Stage 2 設計案: poly-as-set 型表現

Stage 1 (`narrow_param_types_from_body_method_calls`、commit `0d10645`) の制約「呼ばれる全メソッドが**ただ1つ**のクラスにしかない」を外すための、内部型表現の拡張案。記録目的。実装は未着手。

## 動機

現状の "poly" は不透明な単一トークン。次の精度向上が手に入っていない:

1. **set-intersection narrowing** — 候補集合を観測ごとに intersect して絞る
   ```ruby
   def render(model)
     model.title  # Article のみ → {Article}
     model.body   # Article + Comment → {Article, Comment}
     # 交差 = {Article} → narrow できるはず
   end
   ```
   Stage 1 では `model.body` の信号がぼやけて捨てられる。

2. **else-arm 負の絞り込み** — `if x.is_a?(A); ... ; else; # x:NOT(A) ; end`
   現在 scan_new_calls の comment にも明示:
   > The else-arm walks unchanged (we don't currently model "type minus C")

3. **emit サイズ削減** — `compile_poly_method_call` の per-class arm が `@cls_names` を全列挙。候補集合に絞れば未到達 arm を消せる。

## 内部表現

### 文字列エンコード案

`"poly"` → `"poly{<sorted-class-name-list>}"` (集合を文字列でエンコード):

```
"poly"             → 既存の "全クラス" 意味、互換維持のため keep
"poly{Article}"    → 単一クラス、`obj_Article` と等価扱いで折り畳み可能
"poly{Article;Comment}"          → 二項
"poly{Article;Comment;HWIA}"     → 三項
"poly{Article;Comment;HWIA}?"    → nullable版 (既存の `?` サフィックス慣習継承)
```

セパレータは `;` (既存の `@cls_meth_params` のクラス区切り `|` や param 区切り `,` と衝突しない、`@cls_meth_names` の method 区切りと一致)。

### 正規化ルール

- ソートして決定的なエンコードに (`{B;A}` ではなく `{A;B}`)
- 重複除去
- サイズ 1 → `obj_<C>` に折り畳み (representation lift; 集合表現を消す)
- 全クラスを含む → `"poly"` に折り畳み (degenerate case)

### 影響を受ける関数 (主要)

| 関数 | 既存ロジック | 必要な拡張 |
|------|-------------|------------|
| `base_type` | `"obj_C?"` → `"obj_C"` | `"poly{A;B}?"` → `"poly{A;B}"` |
| `is_obj_type` | `"obj_"` プレフィックス判定 | (poly-set は obj_ ではない、独立)  |
| `is_value_type_obj` | obj_C の class lookup | poly-set は value-type 不可 (各候補は struct 化 NG) |
| `c_type` | `"poly"` → `"sp_RbVal"` | `"poly{...}"` も同じく `"sp_RbVal"` |
| `c_default_val` | `"poly"` → `"sp_box_nil()"` | 同 |
| `unify_call_types` | 二項 unify | set union (詳細下記) |
| `box_value_to_poly` | obj_C / 各種 → sp_box_* | set 経由は対象外、各 candidate ごとに caller 側で box済を期待 |

### unify_call_types の拡張

```
unify("poly{A;B}", "obj_A")        = "poly{A;B}"        (subset → 包含)
unify("poly{A;B}", "obj_C")        = "poly{A;B;C}"      (union)
unify("poly{A;B}", "poly{B;C}")    = "poly{A;B;C}"      (union)
unify("poly{A;B}", "poly{A;B}")    = "poly{A;B}"        (idempotent)
unify("poly{A;B}", "int")          = "poly"             (混合型は既存 poly に degrade)
unify("obj_A", "obj_B")            = "poly{A;B}"        (新ロジック; 現状は "poly")
unify("poly", any)                 = "poly"             (degenerate keep)
```

ポイント: **混合型 (obj+primitive) は既存の不透明 `"poly"` に落とす**。これにより既存コードの `"poly"` 判定 (受け取り側のすべての場所) と互換が取れる。`"poly{...}"` は **すべて user obj** な集合に限定。

### intersection 演算 (Stage 1 を一般化)

```
intersect("poly{A;B;C}", "poly{B;C;D}") = "poly{B;C}"
intersect("poly{A;B}", "poly{C;D}")     = ""             (空 → 信号矛盾)
intersect("poly{A}", "obj_A")           = "obj_A"
intersect("poly{A;B}", "obj_C")         = ""             (空)
```

Stage 1 の `unify_param_class_from_observations` を集合演算で書き直す:
- 各観測 `param.<m>` で「`<m>` を定義する user class 集合 S(m)」を計算
- 各観測の S(m) で intersection を取る
- `is_primitive_shared_method(m)` は S に「全クラス + builtins」を意味するので intersection 中立 (skip)
- 最終 intersection が空でなければ narrow

### type minus 演算 (else-arm)

```
type_minus("poly{A;B;C}", "obj_A") = "poly{B;C}"
type_minus("poly{A;B}", "obj_A")   = "obj_B"             (size 1 折り畳み)
type_minus("poly{A}", "obj_A")     = ""                  (空; unreachable)
type_minus("poly", "obj_A")        = "poly"              (不透明は触らない)
```

scan_new_calls の IfNode 処理に else-arm narrow を追加:
```ruby
# then-arm
if narrow_var != ""
  push_type_narrow(narrow_var, narrow_t)  # 既存
end
walk(then_body)
pop

# else-arm (新規)
else_narrow_t = type_minus(原型, narrow_t)
if else_narrow_t != ""
  push_type_narrow(narrow_var, else_narrow_t)
end
walk(else_body)
pop
```

## emit-side 変更

### compile_poly_method_call

```ruby
# 現状:
i = 0
while i < @cls_names.length
  midx = cls_find_method_direct(i, mname)
  if midx >= 0
    # arm 出力
  end
  i += 1
end

# Stage 2:
candidates = poly_candidates(recv_type)   # "poly{A;B}" → ["A", "B"]
# 候補が空 (= 不透明 "poly") なら現状通り全列挙
# 候補があれば限定列挙
candidates.each { |cn|
  ci = find_class_idx(cn)
  midx = cls_find_method_direct(ci, mname)
  if midx >= 0
    # arm 出力
  end
}
```

emit 量削減: Roundhouse 規模 (~20 user class、平均候補3クラス) で arm 17 個 ÷ poly call sites 50-100 個 ≈ 1000-2000 行の C 削減 (runtime 動作に影響なし、cc 時間 + emit サイズのみ)。

### sp_RbVal タグの動作変化なし

ランタイムの sp_RbVal/cls_id 機構は変更不要。集合は **静的判定** だけの情報。runtime は cls_id で正しく分岐。

## 不動点の収束

Stage 2 では union (拡大) と intersection (縮小) の両方を扱う:

- caller→callee widening (scan_new_calls): union で拡大
- callee→caller (戻り値伝播): union で拡大
- body-side narrow (Stage 1 拡張): intersection で縮小

各 round 内の順序を:
1. union 系 (call-site 観測) を全部走らせて param ptype を膨らませる
2. その後で intersection 系 (body 観測) を走らせて絞る

→ "拡大→縮小" の順序が各 round で一定なら、実質単調に近づく。`inference_signature` で前回と等しくなったら stop。最大 round 数を上げる必要があるかもしれない (現状 4 → 6〜8 程度に)。

## 互換性 / 移行ステップ

Stage 2 を 1 PR で全部入れるのは bootstrap risk が高い。段階移行:

### 2a. 表現拡張 (no-op)
- `"poly{A;B}"` 文字列を内部で生成する経路を入れるが、すべて `"poly"` に折り畳んで返す
- `unify_call_types` などはまだ既存挙動
- すべての判定箇所が新表現を view できることを bootstrap で確認

### 2b. set-intersection narrow
- Stage 1 の単一クラス制約を外す
- `unify_param_class_from_observations` を set intersection で書き直す
- 既存の `"poly"` への混合型 degrade はそのまま

### 2c. else-arm 負の絞り込み
- IfNode の else-arm に type_minus 適用
- recursive scan のスコープ管理を慎重に (then と else で違う narrow)

### 2d. emit-side 列挙の限定
- `compile_poly_method_call` で候補集合があればそれを使う
- emit 出力差を 1 PR で分離 (review しやすさのため)

## リスクと観察ポイント

1. **bootstrap stability**: 型文字列処理の 1 箇所のミスで gen2 != gen3 → CI 全敗
   - 各サブステップ後 `make bootstrap` 必須
   - 表現変更前に既存 split/join ロジックの全数 grep し、新セパレータ衝突の有無を確認

2. **テスト盲点**: 
   - 集合サイズ 0 (空 = unreachable) のハンドリング
   - サイズ 1 → obj_<C> 折り畳みの一貫性
   - 全クラス集合と "poly" の等価扱い

3. **ROI 計測**:
   - Stage 2a 完了時点で既存テスト + Roundhouse archive で no-op 確認
   - Stage 2b 後、stage 1 で narrow できなかった param が集合 narrow できる事例を 1 つ以上見つける (見つからないなら投資中止判断材料)
   - Stage 2c, 2d は 2b の効果を見て継続判断

## 着手判断条件

Stage 2 に踏み込むべきタイミング:

- `caller-side widening が届かない経路` 起源でない、**型精度**起源のバグが具体例で現れた時
- Roundhouse 移行が runtime 段階に入って "static dispatch ミス" が顕在化した時
- emit サイズ・cc 時間のボトルネックが計測で示された時 (現状は CI 11分問題は sccache miss 由来で、emit サイズではない)

それまでは Stage 1 で観察を継続。

---

参考:
- Stage 1: `narrow_param_types_from_body_method_calls` (`0d10645`)
- 関連コメント: `spinel_codegen.rb` の `scan_new_calls` IfNode 処理 ("we don't currently model 'type minus C'")
- 既存集合的ロジックの先例: `module_acc_resolved` のセミコロン区切りクラス候補リスト (#126)
