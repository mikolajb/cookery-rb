Conditions = Hash.new

def condition(name, &block)
  Conditions[name] = block
end
