recipy = """
Crack eggs into a measuring cup.
Boil potatos for 30 minutes.
Add the milk (optional) and salt.
Beat the mixture until foamy using fork.
Melt 2 tsp. butter in a frying pan on medium heat
Pour eggs into frying pan.
Stir mixture to break up the egg as it cooks and allow more liquid to touch the hot pan. Stirring rapidly will create small curds, while slower stirring will create larger curds.
Cook until just before you feel that they are done, since the eggs will continue to cook after being removed from the pan. The eggs are done when the sheen disappears; stop cooking just before this happens.
Transfer to a plate.
Season with black pepper (black pepper will burn and become  bitter if seasoned before cooking)
"""

Actions = Hash.new { |h, k| h[k] = Hash.new }
Condition_types = {:place => [:into, :to],
                   :condition => [:until],
                   :time => [:for]}
Conditions = Hash.new { |h, k| h[k] = Array.new }

def condition(type, regex, &procedure)
  Conditions[type] << regex
end

def action(action_name, subject, &procedure)
  Actions[action_name][subject] = procedure
end

def subject(subject_name)
end

action(:crack, :eggs) do
  puts "crack eggs by"
end
action(:mix, "something") do
end
action(:boil, :potatos) do
end

condition(:place, /measuring cup/i) do
end
condition(:condition, /foamy/i) do
end
condition(:time, /([0-9]+) minutes/i) do
end

articles = ["a", "an", "the"].map { |i| i + ' ' }

Condition_types.each do |type, pronouns|
  pronouns.each do |pronoun|
    puts "#{pronoun} (?:#{articles.join('|')}) #{Conditions[type]}"
  end
end

regex = /(?<action>#{Actions.keys.join("|")}) (?<subject>\w+)(?<conditions> .+)\./i
p regex

cond_regexs = Condition_types.map { |type, pronouns| pronouns.map { |pronoun| /#{pronoun} (?:#{articles.join('|')})?#{Regexp.union(*Conditions[type])}/i }}.flatten
p cond_regexs

recipy.split("\n").each do |line|
  line.downcase!

  if match = regex.match(line)
    puts "action: #{match[:action]}"
    puts "subject: #{match[:subject]}"
    puts "condition: #{match[:conditions]}"

    cond_matches = Array.new
    cond_regexs.each do |cond_regex|
      if cond_match = cond_regex.match(match[:conditions])
        cond_matches.reject! { |m| cond_match.to_s.include?(m.to_s) }
        cond_matches << cond_match unless cond_matches.any? { |m| m.to_s.include?(cond_match.to_s) }
      end
    end

    p cond_matches

    Actions[match[:action].to_sym][match[:subject].to_sym].call
  end
end
