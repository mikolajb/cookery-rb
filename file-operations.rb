require_relative 'subject'
require_relative 'action'
require_relative 'channel'
require_relative 'condition'
require_relative 'cookery'
require 'zlib'

subject(:file, /(.+)/, :file) do |f|
  path f
end

action(:read) do |subject|
  puts "in action"

  channel_put(:foo, subject)
end

condition("with zip compression") do |data|
  puts "in condition"
  gz = Zlib::GzipReader.new(StringIO.new(data))
  result = gz.read
  gz.close
  result
end

condition("with nothing") do |data|
  data
end

action(:print_result) do
  puts "RESULT: #{channel_get(:bar)}"
end

action(:count_words) do |subject, conditions|
  channel_put(:bar, channel_get(:foo).split.length)
end

text = """
Read file /tmp/test_data.gzip - with zip compression, with nothing.
Count words.
Print result.
"""

cookery(text)
