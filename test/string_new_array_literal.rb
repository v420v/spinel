# #519. `[String.new]` (and `[s]` where `s = String.new`) used to
# infer as `int_array`, then codegen emitted
# `sp_IntArray_push(arr, sp_String_new(""))` -- C type mismatch.
#
# Fix: `infer_array_elem_type_from_ids` now has a `mutable_str` arm
# that lowers the literal to `mutable_str_ptr_array` (a sp_PtrArray
# of sp_String*). The generic `<X>_ptr_array` codegen path handles
# length / push / pop / [] for the new slot.
#
# `["", String.new]` (mixed string-literal + mutable_str) still
# widens to poly_array because the literal witness flips et to
# "string" first and the all-string check fails.

arr = [String.new]
puts arr.length

s = String.new
arr2 = [s]
puts arr2.length

# Mixed: literal + String.new -> poly_array. Both elements show up.
mixed = ["", String.new]
puts mixed.length
