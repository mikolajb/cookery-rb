action("test", :out) do |data|
  puts "Just a test, passing data from subject"
  data
end

action("load", :in) do |sbj|
  sbj.get
end

subject("Test", nil, "test") do
  "fake result".bytes.map { |i| (i >= 97 and i <= 122 and rand > 0.5) ?
                              i - 32 : i }.pack("c*")
end

subject("File", /(.+)/, "file") do |args|
  puts "FILE"
  p args
end

subject("RemoteFile", /(.+)/, "http") do |args|
  puts "REMOTE FILE"
  url args
  p args
end
