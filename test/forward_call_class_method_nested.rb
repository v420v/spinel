# Nested forward-ref: `Outer.new(Inner.new)` where both Outer and
# Inner are defined later than the construction site. The Inner.new
# nested arg type must propagate to Outer.initialize's param so the
# outer Class.new ptype widens correctly.

class Driver
  def boot
    @outer = Outer.new(Inner.new(42))
  end
  def reach
    @outer.payload.value
  end
end

class Inner
  def initialize(v)
    @v = v
  end
  def value
    @v
  end
end

class Outer
  def initialize(inner)
    @inner = inner
  end
  def payload
    @inner
  end
end

d = Driver.new
d.boot
puts d.reach
