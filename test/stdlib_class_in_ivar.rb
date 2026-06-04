# A stdlib class with no Spinel struct (Mutex, Pathname, OpenStruct,
# IPAddr, ...) stored in an instance variable previously made analyze
# type the ivar `obj_<Class>` and codegen emit an undeclared
# `sp_<Class> *` field, failing the C build with `unknown type name`.
#
# Fix: when a constructor's target class has no struct (not a
# user-defined class), type the slot as int — codegen already lowers
# the unresolved `.new` to integer 0 — so the field compiles. The
# stdlib object itself is inert (its methods stay unresolved), so the
# assertions below only observe ivars that don't depend on it.
require 'thread'
require 'pathname'
require 'ostruct'
require 'ipaddr'

class WithMutex
  def initialize
    @lock = Mutex.new
    @n = 5
  end
  def n
    @n
  end
end

class WithPathname
  def initialize
    @path = Pathname.new('/tmp')
    @v = 7
  end
  def v
    @v
  end
end

class WithOpenStruct
  def initialize
    @os = OpenStruct.new(a: 1)
    @w = 9
  end
  def w
    @w
  end
end

class WithIPAddr
  def initialize
    @ip = IPAddr.new('1.2.3.4')
    @z = 11
  end
  def z
    @z
  end
end

puts WithMutex.new.n          #=> 5
puts WithPathname.new.v       #=> 7
puts WithOpenStruct.new.w     #=> 9
puts WithIPAddr.new.z         #=> 11

# Local (not ivar) constructor of an unresolved class also compiles.
local_obj = Mutex.new
puts "local ok"

# A user-defined class is unaffected — it keeps its obj_<Class> slot.
class Point
  def initialize(x)
    @x = x
  end
  def x
    @x
  end
end

class Holder
  def initialize
    @p = Point.new(42)
  end
  def px
    @p.x
  end
end

puts Holder.new.px            #=> 42
puts "done"
