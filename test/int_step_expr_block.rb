# Integer#step with a block in expression position — CRuby returns
# the receiver, not 0. Previously fell through to the unresolved-
# call path and emitted 0 (and analyze inferred int_array, which
# then SEGV'd when result was used as a pointer).
result = 1.step(5) { |x| x }
puts result.inspect
puts result.class
