class Foo
  def self.with(&block)
    block.call(42)
  end
end

Foo.with { |n| puts n }
