# Issue #647: a top-level `CONST = recv.method` initializer whose
# RHS reads a main-scope local used to emit BEFORE the body
# statements ran. Codegen's const-init pre-loop planted
# `cst_X = lv_y.iv_z;` at the top of `main`, before `lv_y =
# sp_Y_new()` ever ran, so the chain read from a zero-initialized
# struct and the const ended up as 0 (or SIGSEGV when the call
# reached FFI). Reporter hit the FFI crash variant in tinynn
# config loading.
#
# Fix (PR #648): expr_reads_main_local detects the dependency,
# the pre-loop skips flagged consts, and the body-statement loop
# emits them in source order — by then the local has been
# assigned.

class Cfg
  attr_reader :nested
  def initialize(n); @nested = n; end
end

class Inner
  attr_reader :v
  def initialize; @v = 42; end
end

inner = Inner.new
cfg = Cfg.new(inner)
CFG_VOCAB = cfg.nested.v   # ← used to read zero-init lv_cfg, returns 0
puts CFG_VOCAB.to_s
