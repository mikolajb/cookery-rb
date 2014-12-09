require 'citrus'
require 'colored'

Citrus.load 'cookery'

texts = ["Test: read File.",
         "read with something.",
         "read.",
         "Test: read File with something.",
         "Test: read File file:///tmp/test.txt with something."]

texts.each do |t|
  puts t.magenta
  begin
    c = Cookery.parse t

    [:variable, :action, :subject, :arguments].each do |elem|
      puts "#{elem}" + "\t" * ((23 - elem.length) / 8) +
           (c.captures.include?(elem) ? c.captures[elem].join(", ").green : "NO".red)
    end

    if c.captures.include?(:condition_group)
      puts "conditions\t" + c.capture(:condition_group)[:condition].join(", ").green
    else
      puts "conditions\t" + "NO".red
    end

    p c.captures
    puts ("-" * 80).yellow
  rescue Citrus::ParseError => e
    puts "PARSING FAILD".red
    p e
  end
end
