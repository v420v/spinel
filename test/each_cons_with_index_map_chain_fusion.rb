# Phase A.3 of Enumerator-chain strategy (#566): three-step
# `arr.each_cons(n).with_index(off).map { ... }` chain. CRuby
# returns an Enumerator from each_cons, then another from
# with_index, and consumes both at the terminal .map. Spinel
# fuses the whole chain into a single C loop with an idx counter
# initialised from `off` (default 0) and incremented after each
# pair, so no Enumerator object is allocated.
#
# Block param shapes:
#   |pair, i|       -- pair is the typed sub-array, i is the int idx
#   |(a, b), i|     -- nested destructure of pair into individual
#                      window slots (skips the per-iteration sub-
#                      array allocation), trailing i as int idx

# T1: |pair, i| with explicit offset
p [10, 20, 30, 40].each_cons(2).with_index(1).map { |pair, i| pair[0] + pair[1] + i }

# T2: |(a, b), i| destructure, explicit offset
p [10, 20, 30, 40].each_cons(2).with_index(1).map { |(a, b), i| b - a + i }

# T3: default offset (0)
p [1, 2, 3].each_cons(2).with_index.map { |pair, i| pair[1] - pair[0] + i }

# T4: block returns array -> result is int_array_ptr_array
p [1, 2, 3, 4].each_cons(2).with_index(1).map { |(a, b), i| [b - a, i] }
