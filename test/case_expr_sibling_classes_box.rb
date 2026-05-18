# #580 (Sam Ruby). A `case` expression whose `when` branches
# return instances of unrelated sibling classes typed the overall
# result as sp_RbVal at the expression level, but the per-branch
# emit assigned the raw `sp_<Class> *` pointer into the sp_RbVal
# slot. C rejected the assignment with `incompatible types`.
#
# Fix: route each arm's last expression through box_when_arm_to_
# target, which inserts sp_box_obj (or whatever box_value_to_poly
# resolves to for the arm's type) when the unified target is poly
# and the arm's static type is something narrower.

class A
  def name; "A-instance"; end
end

class B
  def name; "B-instance"; end
end

n = 1
x = case n
    when 0 then A.new
    when 1 then B.new
    end
puts x.is_a?(A)
puts x.is_a?(B)
