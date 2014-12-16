$:.unshift File.dirname(__FILE__)

require 'cookery'

texts = eval(File.open(File.join(File.dirname(__FILE__), 'test-cases2.rb')).read)

counter = 0
texts.each do |t, s|
  begin
    c = Cookery.parse(t)

    if s != :skip and c.value != s
      puts "parsing... " + t.magenta
      puts "NOT MATCHING".red
      puts "result is: #{c.value.inspect.blue}".red
      puts "it was suppose to be #{s.inspect.blue}".red

      p c.captures

      puts ("-" * 80).yellow
      next
    end

    counter += 1
  rescue Citrus::ParseError => e
    puts t.magenta
    puts "PARSING FAILD".red
    puts e.detail

    puts ("-" * 80).yellow
  end
end

puts
puts "\t#{counter} / #{texts.length} passed".send(
       counter == texts.length ? :green :
         counter == 0 ? :red : :yellow)
puts
