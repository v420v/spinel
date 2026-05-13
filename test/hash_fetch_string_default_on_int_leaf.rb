# #454: `params.fetch "k", ""` on a Hash[String, Int] (or
# Hash[Symbol, Int]) emitted a type-mismatched ternary
# (`has_key ? get_int : char_star_default`) and failed C compile
# under -Werror=int-conversion.
#
# Narrow fix: when the default is a string literal and the hash
# leaf is int, widen the call's static return type to "string"
# and route the get arm through sp_int_to_s so both arms agree
# on `const char *`. Limited to (int leaf + string default);
# broader (poly leaf, hash default, etc.) cascades through the
# `is_a?(Hash)` narrowing in real-blog params and is left for
# a follow-up.

class P
  def self.lookup_str(params)
    params.fetch "title", ""
  end

  def self.lookup_sym(params)
    params.fetch :title, ""
  end
end

# Hit path: the integer at the key gets stringified.
puts P.lookup_str({ "x" => 1, "title" => 42 })
# Miss path: the empty-string default.
puts P.lookup_str({ "x" => 1 })

# Sym-keyed counterpart.
puts P.lookup_sym({ x: 1, title: 99 })
puts P.lookup_sym({ x: 1 })

# Matched-default control (no fix needed; existing behavior).
class Q
  def self.lookup(params)
    params.fetch "x", 0
  end
end
puts Q.lookup({ "x" => 7 })
puts Q.lookup({ "other" => 1 })
