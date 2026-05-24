# `for a, b in coll` destructures each element into multiple LVs.
for a, b in [[1, 2], [3, 4]]
  puts "#{a}, #{b}"
end

# With strings
for s, n in [["a", 1], ["b", 2], ["c", 3]]
  puts "#{s}=#{n}"
end
