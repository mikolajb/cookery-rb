$:.unshift File.dirname(__FILE__)

require 'cookery'

texts = eval(File.open(File.join(File.dirname(__FILE__), 'test-cases.rb')).read)

counter = 0
texts.each do |t, s|
  begin
    puts "parsing... " + t.inspect.magenta
    new_file t
    cookery = Cookery.new
    c = cookery.parse(t)

    if s != :skip and c.value != s
      puts "NOT MATCHING".red
      puts "#{c.value.inspect.blue} <- result".red
      puts "#{s.inspect.blue} <- suppose to be".red
      puts c.value.blue
      puts s.blue

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
