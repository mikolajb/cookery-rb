def channel_put(name, value)
  puts "adding #{value} to channel #{name}"
  Channels[name] << value
end

def channel_get(name)
  Channels[name].shift
end

Channels = Hash.new { |h, k| h[k] = Array.new }
