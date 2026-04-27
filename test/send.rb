# Test send(:literal_symbol)
# Note: send rewrite requires Ruby parser (spinel_parse.rb)
x = [1,2,3]
puts x.length

class Adder
  def initialize(n)
    @n = n
  end
  def add(x)
    @n + x
  end
end
a = Adder.new(10)
puts a.add(5)
