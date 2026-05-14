# #497. Regression guard for the optcarrot APU::Pulse shape that
# motivated reverting #495: an ivar initialized to `nil` and later
# used purely as int arithmetic (no `.nil?` read anywhere on it)
# must stay at `int` storage. The pre-revert widening cascaded
# `@wave_length` to poly via scan_writer_calls's new nil branch,
# which then forced `@freq = (@wave_length + 1) * 2 * @fixed`
# to a poly expression and broke every downstream `iv_freq`,
# `iv_timer`, `iv_step` arithmetic site under -Werror.
#
# Test asserts both program output AND the implicit -Werror=int-
# conversion compile (the harness drops cc stderr but a widened
# ivar would surface as a missing binary / wrong output).

class APUFake
  def initialize
    @wave_length = nil
    @fixed = 1
    @freq = 0
    @timer = 0
    @step = 0
  end

  def configure(n)
    @wave_length = n
    @freq = (@wave_length + 1) * 2 * @fixed
    @timer = @freq
  end

  def step!
    @step = (@step + 1) & 7
    @timer += @freq
    @step
  end

  def report
    @step.to_s + "," + @timer.to_s
  end
end

a = APUFake.new
a.configure(3)
puts a.report
a.step!
a.step!
puts a.report
