class A
  attr_reader :x
  def initialize; @x = 11; end
end
class B
  attr_reader :y
  def initialize; @y = 22; end
end
class C
  attr_reader :z
  def initialize; @z = 33; end
end

class Driver
  def self.load
    a = A.new
    b = B.new
    c = C.new
    return a, b, c
  end
end

class Holder
  def initialize
    @a, @b, @c = Driver.load
  end
  def show
    puts "a.x=#{@a.x} b.y=#{@b.y} c.z=#{@c.z}"
  end
end

h = Holder.new
h.show
