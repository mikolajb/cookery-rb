require 'colors'

def cookery(text)
  actions = Actions.keys.map { |a| Regexp.new(a.to_s.sub('_', ' '))}

  p regex = /(?<action>#{Regexp.union(*actions)}) ?(?<subject>#{Regexp.union(*Subjects.keys.map(&:to_s))})? ?(?<arguments>#{Regexp.union(*Subjects.values.map(&:arguments))})?/i

  p cond_regex = /(?:with )?(?<condition>#{Regexp.union(*Conditions.keys)})/


  text.split("\n").each do |line|
    if line.empty? or line[-1] != '.'
      next
    else
      line = line[0...-1]
    end

    puts "- " * 20
    line.downcase!

    variable = nil
    variable, activity, conditions = line.split(/[:-]/).map(&:strip) if /^\w+:/ =~ line
    activity, conditions = line.split('-').map(&:strip)
    puts "parsed: |#{variable}| |#{activity}| |#{conditions}|".hl(:lightblue)

    if match = regex.match(activity)
      puts "detect action: #{match[:action]}".hl(:lightblue)
      puts "detect subject: #{match[:subject]}".hl(:lightblue)
      puts "detect arguments: #{match[:arguments]}".hl(:lightblue)

      action_name = match[:action].sub(' ', '_').to_sym

      condition_names = Array.new
      conditions.scan(cond_regex) do |cond_match|
        condition_names << cond_match.first
      end unless conditions.nil?

      if match[:subject]
        Subjects[match[:subject].to_sym].args(match[:arguments])
        res = Actions[action_name].act(subject: Subjects[match[:subject].to_sym],
                                       conditions: condition_names.map { |cn|
                                         Conditions[cn]},
                                       last_result: last_result_get)
        last_result_set(res)
        set_variable(variable, res) if variable
      else
        Actions[action_name].act(last_result: last_result_get)
      end
    end
  end
end
