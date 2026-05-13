# Sequel to hash_fetch_hash_default: when `params.fetch "k", {}`
# is followed by `is_a?(Hash)` narrowing into an if-expression
# whose else arm returns an empty hash, the receiving local was
# typed as the concrete hash variant (str_int_hash) by the
# pass-1 scan_locals (the if-expr's then-arm reads raw_sub but
# raw_sub is still in the deferred-declaration window), then
# stuck there because the pass-2 merge had no "concrete → poly"
# rule. The codegen-emitted assignment then puts an sp_RbVal
# poly into the typed slot, failing C compile with
# `incompatible types when assigning to type 'sp_StrIntHash *'
#  from type 'sp_RbVal'`.

class ArticleParams
  def self.from_raw(params)
    raw_sub = params.fetch "article", {}
    sub = if raw_sub.is_a?(Hash)
      raw_sub
    else
      {}
    end
    sub.is_a?(Hash) ? "got-hash" : "no-hash"
  end
end

puts ArticleParams.from_raw({ "x" => 1 })
puts ArticleParams.from_raw({ "y" => 2 })
