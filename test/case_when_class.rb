# case/when with class predicates (issue #67)

class Var; end
class List; end
class Pair; end

node = Var.new
case node
when Var
  puts "var"
when List
  puts "list"
end

node2 = List.new
case node2
when Var
  puts "var"
when List
  puts "list"
when Pair
  puts "pair"
end

# Multiple classes in one when arm
node3 = Pair.new
case node3
when Var, List
  puts "var or list"
when Pair
  puts "pair"
end

# With else
node4 = Var.new
case node4
when List
  puts "list"
else
  puts "not list"
end

# Inheritance: when superclass matches subclass instance
class Animal; end
class Dog < Animal; end
class Cat < Animal; end

d = Dog.new
case d
when Dog
  puts "dog"
when Animal
  puts "animal"
end

c = Cat.new
case c
when Dog
  puts "dog"
when Cat
  puts "cat"
end

a = Animal.new
case a
when Dog
  puts "dog"
when Animal
  puts "animal"
end

# As return value in a method (single-type parameter)
def describe_var(obj)
  case obj
  when Var
    "is var"
  else
    "not var"
  end
end

puts describe_var(Var.new)
