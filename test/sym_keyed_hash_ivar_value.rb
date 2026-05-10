# Issue #415. A `{ sym_key: <ivar-or-param> }` hash literal whose
# values are NOT string literals -- ivars, params, method-call
# results -- compiled to a C reference of `sp_SymStrHash *` without
# the matching typedef + helpers in the same translation unit, so
# the cc step failed with "unknown type name 'sp_SymStrHash'".
#
# Root cause: `infer_hash_val_type` returned the inferred hash
# variant string ("sym_str_hash" etc.) without flagging the
# template-instantiation need, so `@needs_sym_str_hash` stayed at
# 0 and `emit_hash_runtime` skipped the typedef. The string-literal
# case happened to work because a separate write path through
# `compose_hash_type` flagged it via that route.
#
# Fix: route `infer_hash_val_type`'s return value through
# `mark_hash_needs` so every observed hash variant flags its
# template need, regardless of whether the values are literals.
#
# Coverage:
#   - sym_str_hash from an ivar value (the canonical issue shape).
#   - sym_str_hash from a method param (same gap, different write).
#   - mixed-shape attributes hash with a method-call value (proves
#     the path also reaches through CallNode-typed values).

class Foo
  attr_reader :title

  def initialize
    @title = "hello"
  end

  def attributes
    { title: @title }
  end

  def with_extra(more)
    { title: @title, extra: more }
  end
end

f = Foo.new
puts f.attributes[:title]       # hello
puts f.with_extra("world")[:extra]  # world

class Bar
  def initialize
    @body = "lorem"
  end

  def to_h
    { body: @body, len: @body.length.to_s }
  end
end

b = Bar.new
puts b.to_h[:body]              # lorem
puts b.to_h[:len]               # 5
