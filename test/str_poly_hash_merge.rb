# Issue #426. `Hash#merge` was unresolved on a `str_poly_hash`
# (mixed-value-type hash literal) -- emit produced `0` and the
# downstream `m.length` cascaded through int. Same shape on
# monomorphic-value hashes (`str_int_hash`, `str_str_hash`)
# worked; the gap was just the polymorphic-value specialization.
#
# Fix:
#   - Runtime: sp_StrPolyHash_merge(a, b) in lib/sp_runtime.h,
#     same shape as the existing sp_StrIntHash_merge /
#     sp_SymPolyHash_merge helpers.
#   - Codegen: `compile_hash_method_expr`'s str_poly_hash arm
#     gains a `merge` case. Dispatches by arg type:
#       * str_poly_hash arg -> sp_StrPolyHash_merge direct.
#       * str_str_hash arg -> inline copy with sp_box_str on
#         each value to land in poly slots.
#       * str_int_hash arg -> inline copy with sp_box_int.
#
# Out of scope: poly-typed args (sp_RbVal whose runtime hash
# variant is unknown statically) -- needs the runtime-dispatch
# pattern from sym_poly_hash's poly-arg branch, not in this
# minimal fix.
#
# Coverage:
#   - canonical mixed-value seed + str_int_hash override (the
#     repro from #426).
#   - mixed-value seed + str_str_hash override (forces the
#     box_str copy path).
#   - mixed-value seed + str_poly_hash override (the direct
#     merge path; verifies it's still reachable post-fix).

h = { "a" => 1, "b" => "two" }  # str_poly_hash
m = h.merge({ "c" => 3 })       # str_int_hash arg
puts m.length                    # 3
puts m["a"] == 1 ? "a-ok" : "a-bad"
puts m["c"] == 3 ? "c-ok" : "c-bad"

# str_str_hash override of a str_poly_hash recv.
h2 = { "x" => 1, "y" => "two" }
m2 = h2.merge({ "z" => "three" })
puts m2.length                   # 3
puts m2["z"] == "three" ? "z-ok" : "z-bad"

# str_poly_hash override of a str_poly_hash recv.
h3 = { "p" => 1, "q" => "two" }
extra = { "r" => 3, "s" => "four" }
m3 = h3.merge(extra)
puts m3.length                   # 4
