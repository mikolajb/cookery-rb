require_relative 'subject'
require_relative 'action'
require_relative 'channel'
require_relative 'condition'
require 'zlib'


subject(:file, /(.+)/, :file) do |f|
  path f
end

action(:read, :file) do |subject, conditions|
  puts "in action"
  x = subject.get()
  gz = Zlib::GzipReader.new(StringIO.new(x))
  channel_put(:foo, gz.read)
  gz.close
end

condition(:zip_compression) do |subject|
  gz = Zlib::GzipReader.new(StringIO.new(subject.get()))
  result = gz.rezd
  gz.close
  result
end

action(:print_result) do
  puts "RESULT: #{channel_get(:bar)}"
end

action(:count_words) do |subject, conditions|
  channel_put(:bar, channel_get(:foo).split.length)
end

text = """
Read file /tmp/test_data.gzip - with zip compression.
Count words.
Print result.
"""

actions = Actions.keys.map { |a| Regexp.new(a.to_s.sub('_', ' '))}

p regex = /(?<action>#{Regexp.union(*actions)}) ?(?<subject>#{Regexp.union(*Subjects.keys)})? ?(?<arguments>#{Regexp.union(*Subjects.values.map(&:arguments))})?/i

conditions = Conditions.keys.map { |c| Regexp.new(c.to_s.sub('_', ' ')) }

p cond_regex = /(?:with )?(?<condition>#{Regexp.union(*conditions)})/

text.split("\n").each do |line|
  if line.empty? or line[-1] != '.'
    next
  else
    line = line[0...-1]
  end

  puts "- " * 20
  line.downcase!

  activity, conditions = line.split('-').map(&:strip)
  puts "activity: #{activity}"
  puts "conditions: #{conditions}"
  puts

  if match = regex.match(activity)
    puts "action: #{match[:action]}"
    puts "subject: #{match[:subject]}"
    puts "arguments: #{match[:arguments]}"
    # puts "condition: #{match[:conditions]}"

    action_name = match[:action].sub(' ', '_').to_sym

    if cond_match = cond_regex.match(conditions)
      p cond_match
    end

    if match[:subject]
      Subjects[match[:subject].to_sym].args(match[:arguments])
      Actions[match[:action].to_sym].act(Subjects[match[:subject].to_sym])
    else
      Actions[action_name].act
    end


  end
end
