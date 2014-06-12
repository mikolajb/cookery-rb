require_relative 'subject'
require_relative 'action'

subject(:file, /(.+)/, :file) do |f|
  path "/tmp/test_data.txt"
end

action(:read, :file) do |subject, conditions|
  puts "in action"
  p subject.get()
end

action(:write, :file) do |subject, conditions|
end

action(:count_words) do |subject, conditions|
end

text = """
Read file '/tmp/test_data.txt' - with zip compression.
Count words.
Print output data.
"""

# regex = /(?<action>#{Actions.keys.join("|")}) (?<subject>\w+)/i
regex = /(?<action>#{Actions.keys.join("|")}) (?<subject>#{Regexp.union(*Subjects.keys)}) ?(?<arguments>#{Regexp.union(*Subjects.values.map(&:arguments))})?/i
p regex

# cond_regexs = Condition_types.map { |type, pronouns| pronouns.map { |pronoun| /#{pronoun} (?:#{articles.join('|')})?#{Regexp.union(*Conditions[type])}/i }}.flatten
# p cond_regexs


text.split("\n").each do |line|
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

    Actions[match[:action].to_sym].act(Subjects[match[:subject].to_sym])

    # cond_matches = Array.new
    # cond_regexs.each do |cond_regex|
    #   if cond_match = cond_regex.match(match[:conditions])
    #     cond_matches.reject! { |m| cond_match.to_s.include?(m.to_s) }
    #     cond_matches << cond_match unless cond_matches.any? { |m| m.to_s.include?(cond_match.to_s) }
    #   end
    # end

    # p cond_matches

    # Actions[match[:action].to_sym][match[:subject].to_sym].call
  end
end
