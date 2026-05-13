# `Hash#fetch(key, {})` on an int-leaf hash. Sequel to #454 which
# closed the string-default case via sp_int_to_s conversion. The
# hash-default case can't unify the two ternary arms to a single
# primitive: get returns int, default is a hash pointer. Box both
# arms to sp_RbVal and surface the return type as poly.

class P
  def self.lookup_present(params)
    params.fetch "x", {}
  end

  def self.lookup_missing(params)
    params.fetch "missing", {}
  end
end

box = { "x" => 7 }
v1 = P.lookup_present(box)
v2 = P.lookup_missing(box)
# Hit path returns the int value (boxed)
puts v1.is_a?(Integer) ? v1 : "non-int"
# Miss path returns the empty hash (boxed)
puts v2.is_a?(Hash) ? "hash" : "non-hash"
