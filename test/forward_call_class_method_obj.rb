# `Class.new(obj_X)` shape: caller passes a user-class instance to a
# forward-defined Class.new. Mirrors the optcarrot
# `PPU.new(@conf, @cpu, @video.palette)` site where the callee's
# obj-typed param flowed in from a yet-to-be-defined sibling class.

class Holder
  def initialize(name)
    @name = name
  end
  def label
    "h:#{@name}"
  end
end

class Caller
  def make
    @h = Holder.new("alpha")
    @t = Target.new(@h)
  end
  def show
    @t.held_label
  end
end

class Target
  def initialize(h)
    @holder = h
  end
  def held_label
    @holder.label
  end
end

c = Caller.new
c.make
puts c.show
