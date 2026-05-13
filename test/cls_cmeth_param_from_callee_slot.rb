# Real-class class method (`def self.X`) param back-propagation:
# a body that forwards a param to a sibling cmeth whose slot is
# `void *` (or an obj pointer) should widen the outer param to
# the same pointer type.
#
# Symmetric to the closed sibling case for module class methods
# (test/param_ptr_from_callee_slot.rb). The earlier pass only
# walked @meth_* (top-level and module synthetics); real-class
# cmeths live in @cls_cmeth_* and were skipped.
#
# Also pins the literal-zero unification: passing `0` to a
# pointer-typed slot is C's null-pointer-constant, not a genuine
# poly. Prior to the fix, `column_bool(0, 0)` widened the param
# to poly and overrode the body-derived `void *`.

class Box
  def self.read_int(p)
    p.length
  end

  def self.read_bool(p)
    read_int(p) != 0
  end
end

puts Box.read_int("abc")
puts Box.read_bool("xyz")

# Three-deep sibling chain inside a class (vs the module-class
# sibling test).
class Chain
  def self.head(s)
    middle(s)
  end

  def self.middle(s)
    tail(s)
  end

  def self.tail(s)
    s.length
  end
end

puts Chain.head("hello")
puts Chain.middle("world")
puts Chain.tail("hi")
