# #566 (T.Yamada). Unsupported methods like each_cons /
# with_index emit `0` (NULL) for their result; downstream
# Array#drop / take then call sp_PtrArray_length / _get on
# the NULL pointer and segfault. The methods themselves still
# need real dispatch (separate work), but the runtime helpers
# should never crash on NULL recv -- match the NULL-safe
# pattern sp_StrIntHash_get / sp_PolyArray_length already
# follow.

# This test exercises a chain that previously crashed in main
# after spinel emitted an unresolved-call warning. Output
# remains "0" because the underlying methods aren't yet
# implemented, but exit status is 0 (no segv).

q = [100, 90, 82, 70, 65]
a = 2
b = 4
p q.each_cons(2).with_index(1).map { |(x, y), i| [x - y, i] }.drop(a - 1).take(b - a + 1).max[1]
