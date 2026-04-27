# Symbol-keyed hash with string values
h = {name: "Alice", role: "admin"}
puts h[:name]           # Alice
puts h[:role]           # admin
puts h.length           # 2
puts h.has_key?(:name)  # true
puts h.has_key?(:unknown) # false
h[:email] = "a@b.c"
puts h[:email]          # a@b.c
puts h.length           # 3
