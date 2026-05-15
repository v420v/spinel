# #510. `sym_str_hash` and `sym_poly_hash` got the right type
# tag at analyze time but the codegen dispatch had no arms for
# merge / fetch / dup / delete — every call emitted 0 with a
# "cannot resolve call to '<m>' on sym_<x>_hash" warning.
#
# Fix: added codegen arms for the missing operations, with
# matching runtime helpers (sp_SymStrHash_merge, sp_SymPolyHash_delete)
# emitted alongside the existing sp_SymStrHash_* set / declared in
# the runtime header. fetch's default value is boxed via
# box_expr_to_poly so the ternary's arms agree on sp_RbVal type.
# Analyze: fetch on sym_poly_hash / str_poly_hash returns poly
# (so the receiving LV slot widens to sp_RbVal).

# sym_str_hash.merge
base = { href: "/path" }
extra = { class: "btn" }
puts base.merge(extra).length

# sym_str_hash.dup
h = { a: "1", b: "2" }
d = h.dup
puts d.length

# sym_str_hash.delete
h2 = { a: "1", b: "2", c: "3" }
h2.delete(:b)
puts h2.length

# sym_poly_hash.fetch with default
opts = { method: :delete, form_class: "btn-form", id: 42 }
m = opts.fetch(:method, :nope)
puts m
n = opts.fetch(:missing, :fallback)
puts n

# sym_poly_hash.dup + delete
od = opts.dup
od.delete(:method)
puts od.length
