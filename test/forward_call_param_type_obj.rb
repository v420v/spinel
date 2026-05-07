# Forward-call with a user-class-typed arg flowing through the
# caller's ivar to the callee's parameter slot. Mirrors optcarrot's
# `@ppu.nametables = @mirroring` shape — the callee accepts an
# `obj_<UserClass>` and the int→class fallback dispatches via the
# yet-untyped `@ppu` ivar.

class Holder
  def initialize(name)
    @name = name
  end
  def label
    "h:#{@name}"
  end
end

class Caller
  def initialize(target)
    @target = target
    @holder = Holder.new("alpha")
  end
  def go
    @target.attach(@holder)
  end
end

class Target
  def attach(h)
    @holder = h
  end
  def held_label
    @holder.label
  end
end

t = Target.new
c = Caller.new(t)
c.go
puts t.held_label
