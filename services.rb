require_relative 'subject'
require_relative 'action'
require_relative 'channel'
require_relative 'condition'
require_relative 'cookery'
require 'zlib'

subject(:file, /(.+)/, :file) do |f|
  path f
end

subject(:http, /put (.+)/, :http) do |c|
  url c
end

action(:read) do |subject|
  channel_put(:foo, subject)
end

action(:send_to) do |http_service, last_result|
  http_service.put({:result => last_result})
end

text = """
File: Read file /tmp/test_data.txt.
Send to http put http://localhost:12345.
"""

cookery(text)
