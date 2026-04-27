# String#% with a str_array RHS, routed through sp_str_format_strarr.
# The integer % path (sp_imod) is unchanged — only str_array RHS triggers
# sprintf-style formatting.

# Single placeholder
puts "hello, %s!" % ["world"]            # hello, world!

# Multiple placeholders
puts "%s and %s" % ["a", "b"]            # a and b

# %% literal
puts "100%% of %s" % ["coverage"]        # 100% of coverage

# %s after literal text
puts "[%s][%s][%s]" % ["x", "y", "z"]    # [x][y][z]

# Extra args are ignored (matches CRuby tolerant behavior)
puts "%s" % ["a", "b", "c"]              # a

# Format string with no placeholders, args ignored
puts "no formatting here" % ["x"]        # no formatting here
