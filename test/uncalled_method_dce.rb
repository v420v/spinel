# Issue #393. An uncalled `def f(x); @typed = x; end` whose param
# defaulted to `mrb_int` (no caller pinned the type) tripped a C
# type mismatch against a narrower ivar slot like `const char *`.
#
# Fix: instance methods not reachable from any call site / SymbolNode
# / `super` get a stub body (`(void)params; return default;`).
# `initialize` and operator / conversion methods (`<=>`, `[]`, `to_s`,
# etc.) are always live regardless.

class C
  def initialize
    @body = ""
  end

  # Never called. Param defaults to mrb_int; @body is const char *.
  # Pre-fix: emit assigns `self->iv_body = lv_html` -- type mismatch.
  # Post-fix: body becomes `(void)lv_html; return 0;`.
  def render(html)
    @body = html
  end
end

c = C.new
puts "ok"
