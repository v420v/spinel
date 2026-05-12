# poly_proc_call.rb — verify that .call on a Proc stored in an
# ivar actually invokes the proc body.  Before the fix the dispatch
# body was empty (two separate missing code paths).
# Case 1: Proc stored as sp_RbVal (poly) → emit_poly_builtin_dispatch fix
# Case 2: Proc stored as sp_Proc * (proc) → compile_dot_call_expr fix

class Runner
  def initialize(pr)
    @pr = pr
  end

  def run
    @pr.call
  end
end

class Factory
  def wrap(&block)
    block
  end
end

f = Factory.new

puts "start"
Runner.new(f.wrap { puts "one" }).run
Runner.new(f.wrap { puts "two" }).run
puts "end"
