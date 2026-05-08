# `Class.new(int_array_arg)` where the callee class is defined later
# than the call site. Pre-fix codegen left Target's `arr` param at
# the default `mrb_int`; the int→class fallback then emitted the
# call with a Wint-conversion error. Source order kept caller-first.

class Caller
  def make_target
    @t = Target.new([10, 20, 30])
  end
  def length
    @t.show
  end
end

class Target
  def initialize(arr)
    @arr = arr
  end
  def show
    @arr.length
  end
end

c = Caller.new
c.make_target
puts c.length
