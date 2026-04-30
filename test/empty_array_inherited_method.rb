# Issue #84: an empty `[]` literal passed to an inherited method
# wasn't promoted to a typed array because the caller-side inference
# only updated the receiver class's `@cls_meth_ptypes`, never the
# parent class that actually owns the method body. Body-side
# promotion in `infer_param_array_type_from_body` then saw the slot
# still typed `int`, so the int_array → str_array promotion never
# fired and the C code emitted `mrb_int lv_buf` against an
# `sp_StrArray *` push.
#
# Fix walks the inheritance chain in the caller-side inference: when
# `cls_find_method_direct(child_ci, mname) < 0`, fall back to the
# `find_method_owner` parent and update *its* @cls_meth_ptypes.

class Base
  def add_to(buf)
    buf.push("hi")
  end
end

class Child < Base
end

names = []
Child.new.add_to(names)
names.push("more")
puts names[0]      # hi
puts names[1]      # more

# Two-deep inheritance — Grandchild inherits from Child inherits from
# Base, the empty literal flows through to Base#add_to.
class Grandchild < Child
end

names2 = []
Grandchild.new.add_to(names2)
names2.push("again")
puts names2[0]     # hi
puts names2[1]     # again

# Inherited method on a class that also defines its own method.
# `Mixed#add_to` is its own (different signature), but
# `Mixed#also_add` is inherited from Base2. The promotion must hit
# Base2's slot, not Mixed's.
class Base2
  def also_add(buf)
    buf.push("base2")
  end
end

class Mixed < Base2
  def add_to(buf)
    buf.push(42)
  end
end

ints = []
Mixed.new.add_to(ints)
ints.push(7)
puts ints[0]       # 42
puts ints[1]       # 7

strs = []
Mixed.new.also_add(strs)
strs.push("more")
puts strs[0]       # base2
puts strs[1]       # more
