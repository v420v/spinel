# Regression: `ENV.fetch(key, default)` returns the env value when
# set, otherwise `default`. Pre-fix the codegen emitted "cannot
# resolve call to 'fetch' on int" and segfaulted at runtime.
#
# This test exercises the unset / default-fallback branch, since
# spinel doesn't currently expose `ENV[]=` for setting a var from
# Ruby. The set branch shares the same getenv() path.

# Literal default.
puts ENV.fetch("DEFINITELY_UNSET_VAR_XYZ_42", "fallback-value")

# Default expression need not be a literal.
default = "computed-default"
puts ENV.fetch("ANOTHER_UNSET_VAR_XYZ_42", default)

# Default by string concatenation.
puts ENV.fetch("THIRD_UNSET_VAR_XYZ_42", "pre-" + "fix")
