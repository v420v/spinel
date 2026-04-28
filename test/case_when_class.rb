class Animal
  def initialize(name)
    @name = name
  end
  def name
    @name
  end
end

class Dog < Animal
end

class Cat < Animal
end

# pred_type = obj_Animal, when Animal -> 1 (same class)
a = Animal.new("rex")
case a
when Animal
  puts "animal"
else
  puts "other"
end

# pred_type = obj_Dog, when Animal -> 1 (Dog IS-A Animal)
d = Dog.new("buddy")
case d
when Animal
  puts "animal"
else
  puts "other"
end

# pred_type = obj_Dog, when Dog -> 1 (same class)
case d
when Dog
  puts "dog"
else
  puts "other"
end

# pred_type = obj_Animal, when Dog -> 0 (Dog is a descendant, not statically known)
case a
when Dog
  puts "dog"
else
  puts "not dog"
end

# pred_type = obj_Dog, when Cat -> 0 (unrelated)
case d
when Cat
  puts "cat"
else
  puts "not cat"
end
