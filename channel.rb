def channel_put(name, value)
  puts "adding #{value} to channel #{name}".hl(:green)
  Channels[name] << value
  value #for last_result feature
end

def channel_get(name)
  puts "getting data from channel #{name}".hl(:red)
  Channels[name].shift
end

def last_result_set(result)
  LastResult << result
end

def last_result_get
  LastResult.shift
end

def set_variable(variable, value)
  puts "setting variable #{variable} to #{value}".hl(:yellow)
  Variables[variable] = value
end

Variables = {}
LastResult = []
Channels = Hash.new { |h, k| h[k] = Array.new }
