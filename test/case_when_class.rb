# Issue #67: `case obj when SomeClass` lowered the predicate to an
# `mrb_int` and then compared it against the bare class identifier
# (`Var`, `List`), which weren't declared in C. Two pieces:
#
# - The case-temp now keeps the predicate's pointer type
#   (`sp_<Cls> *`) so the value is comparable as-is.
# - `compile_when_conds` resolves `when ClassName` against an
#   obj-typed predicate at compile time using
#   `is_class_or_ancestor` — same-class or ancestor matches; an
#   unrelated when-class folds to a literal `0`. Nullable predicate
#   types (`obj_<Cls>?`) match only when the value is non-NULL.
#
# Subclass matching against a parent-typed predicate (where the
# instance is actually a child class) needs a runtime cls_id check
# and stays out of scope here.

class Var; end
class List; end

# Statement form — the issue's exact reproducer.
node = Var.new
case node
when Var
  puts "var"
when List
  puts "list"
end
# => var

# Statement form, the other arm wins.
items = List.new
case items
when Var
  puts "var2"
when List
  puts "list2"
end
# => list2

# Expression form — same dispatch, value-returning.
n = Var.new
label = case n
        when Var  then "v"
        when List then "l"
        else            "?"
        end
puts label
# => v

# Else clause when no when arm matches.
class Other; end
class Sentinel; end
o = Other.new
case o
when Var      then puts "x"
when List     then puts "y"
when Sentinel then puts "z"
else               puts "default"
end
# => default

# Inheritance: when arm names an ancestor of the predicate's class.
class Animal; end
class Dog < Animal; end
d = Dog.new
case d
when Animal then puts "ancestor"
else             puts "else"
end
# => ancestor
