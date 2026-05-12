# `def []=(name, value)` whose body dispatches on `name` and writes
# `value` into ivars of differing types (`@id = value` and
# `@name = value`, with `@id: mrb_int` and `@name: const char *`).
# Pre-fix the param was pinned at `mrb_int` from the initialize-time
# observation, and the second ivar assignment errored with
# "incompatible integer to pointer conversion".
#
# widen_param_types_from_body_writes now also looks at
# InstanceVariableWriteNode whose RHS is the param: when two or
# more distinct ivar slot types are observed across such writes
# within a `def []=` body, the param widens to poly. Each branch
# can then unbox / box as the slot demands.

class Foo
  def initialize
    @id = 0
    @name = ""
  end

  def []=(name, value)
    case name
    when :id
      @id = value
    when :name
      @name = value
    end
  end

  def id
    @id
  end

  def name
    @name
  end
end

f = Foo.new
f[:id] = 42
f[:name] = "hello"
puts f.id
puts f.name
