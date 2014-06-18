def cookery(text)
  actions = Actions.keys.map { |a| Regexp.new(a.to_s.sub('_', ' '))}

  p regex = /(?<action>#{Regexp.union(*actions)}) ?(?<subject>#{Regexp.union(*Subjects.keys)})? ?(?<arguments>#{Regexp.union(*Subjects.values.map(&:arguments))})?/i

  p cond_regex = /(?:with )?(?<condition>#{Regexp.union(*Conditions.keys)})/


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

      action_name = match[:action].sub(' ', '_').to_sym

      condition_names = Array.new
      conditions.scan(cond_regex) do |cond_match|
        condition_names << cond_match.first
      end unless conditions.nil?

      if match[:subject]
        Subjects[match[:subject].to_sym].args(match[:arguments])
        Actions[action_name].act(subject: Subjects[match[:subject].to_sym],
                                 conditions: condition_names.map { |cn| Conditions[cn] })
      else
        Actions[action_name].act
      end
    end
  end
end
