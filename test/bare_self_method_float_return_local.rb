class Vec3
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def length2
    @x * @x + @y * @y + @z * @z
  end

  def length
    Math.sqrt(length2)
  end

  def normalize
    len = length
    return Vec3.new(0.0, 0.0, 0.0) if len <= 0.0

    inv = 1.0 / len
    Vec3.new(@x * inv, @y * inv, @z * inv)
  end

  attr_reader :x
end

puts Vec3.new(2.5, 0.0, 0.0).normalize.x
