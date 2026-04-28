# case/when with class predicates (issue #67)

class Var; end
class List; end
class Pair; end
class Animal; end
class Dog < Animal; end
class Cat < Animal; end

# ── Basic class dispatch ──────────────────────────────────────────────────────

case Var.new
when Var  then puts "var"
when List then puts "list"
end

case List.new
when Var  then puts "var"
when List then puts "list"
when Pair then puts "pair"
end

# Multiple classes in one arm
case Pair.new
when Var, List then puts "var or list"
when Pair      then puts "pair"
end

# else branch
case Var.new
when List then puts "list"
else           puts "not list"
end

# ── Inheritance ───────────────────────────────────────────────────────────────

case Dog.new
when Dog    then puts "dog"
when Animal then puts "animal"
end

case Cat.new
when Dog    then puts "dog"
when Cat    then puts "cat"
end

case Animal.new
when Dog    then puts "dog"
when Animal then puts "animal"
end

# ── Methods with class predicates ─────────────────────────────────────────────

# Single-typed parameter: case used as return value
def describe_var(obj)
  case obj
  when Var then "is var"
  else          "not var"
  end
end

puts describe_var(Var.new)   # is var

# Polymorphic parameter: runtime cls_id check
def classify(obj)
  case obj
  when Var  then "var"
  when List then "list"
  else           "other"
  end
end

puts classify(Var.new)   # var
puts classify(List.new)  # list
puts classify(Pair.new)  # other

# Polymorphic parameter with inheritance
def animal_kind(obj)
  case obj
  when Dog    then "dog"
  when Animal then "animal"
  else             "other"
  end
end

puts animal_kind(Dog.new)     # dog
puts animal_kind(Cat.new)     # animal
puts animal_kind(Animal.new)  # animal

# ── Poly variable: obj reassigned to scalar ───────────────────────────────────

poly_int = Var.new
poly_int = 1
case poly_int
when Var  then puts "var"
when List then puts "list"
else           puts "other"
end

poly_str = Var.new
poly_str = "abc"
case poly_str
when Var   then puts "var"
when "abc" then puts "abc"
else            puts "other"
end

poly_flt = Var.new
poly_flt = 3.14
case poly_flt
when Var  then puts "var"
when 3.14 then puts "3.14"
else           puts "other"
end

poly_bool = Var.new
poly_bool = true
case poly_bool
when Var   then puts "var"
when true  then puts "true"
when false then puts "false"
else            puts "other"
end

poly_nil = Var.new
poly_nil = nil
case poly_nil
when Var then puts "var"
when nil then puts "nil"
else          puts "other"
end

poly_sym = Var.new
poly_sym = :hello
case poly_sym
when Var    then puts "var"
when :hello then puts "hello"
else             puts "other"
end

poly_rng = Var.new
poly_rng = 5
case poly_rng
when 1..3 then puts "low"
when 4..6 then puts "mid"
else           puts "other"
end

# ── Poly variable: obj reassigned to array ────────────────────────────────────

# Homogeneous string array
poly_sa = Var.new
poly_sa = ["a", "b"]
case poly_sa
when Var        then puts "var"
when ["a"]      then puts "[a]"
when ["a", "b"] then puts "[a, b]"
else                 puts "other"
end

# Mixed-type array (poly_array)
poly_pa = Var.new
poly_pa = ["a", 2]
case poly_pa
when Var      then puts "var"
when ["a", 1] then puts "a1"
when ["a", 2] then puts "a2"
else               puts "other"
end

# Nested array
poly_na = Var.new
poly_na = ["a", "b", ["x", "y"]]
case poly_na
when ["a", "b"]               then puts "ab"
when ["a", "b", ["x"]]        then puts "abx"
when ["a", "b", ["x", "y"]]   then puts "abxy"
else                                puts "other"
end

# ── Poly variable: when Array matches any array type ─────────────────────────

# str_array matches Array
arr_sa = Var.new
arr_sa = ["a", "b"]
case arr_sa
when Var   then puts "var"
when Array then puts "array"
else            puts "other"
end

# poly_array matches Array
arr_pa = Var.new
arr_pa = ["a", 2]
case arr_pa
when Var   then puts "var"
when Array then puts "array"
else            puts "other"
end

# non-array does not match Array
arr_no = Var.new
arr_no = 42
case arr_no
when Array then puts "array"
else            puts "other"
end
