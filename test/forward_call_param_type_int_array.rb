# File-order caller-first / callee-second: a Caller class invokes a
# method on a yet-untyped ivar (because the callee class is defined
# later in the source). Pre-fix codegen left the callee's params at
# the default `mrb_int` so the IntArray + bool args produced
# "incompatible-pointer" / "Wint-conversion" errors when the
# int→class fallback emitted the call. With the forward-ref widening
# in place the callee picks up `sp_IntArray *` + `mrb_bool` from
# this single call site.

class Caller
  def initialize(target)
    @target = target
    @arr = [1, 2, 3]
    @flag = false
  end
  def go
    @target.set_payload(@arr, @flag)
  end
end

class Target
  def set_payload(arr, flag)
    @arr = arr
    @flag = flag
  end
  def info
    "len=#{@arr.length} flag=#{@flag}"
  end
end

t = Target.new
c = Caller.new(t)
c.go
puts t.info
