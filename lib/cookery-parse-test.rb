$:.unshift File.dirname(__FILE__)
$:.unshift "/home/mikolaj/praca/behavioral/citrus-testing/citrus/lib"
require 'cookery'

texts = eval(File.open(File.join(File.dirname(__FILE__), 'test-cases.rb')).read)

counter = 0
texts.each do |t, p|
  message = ""
  begin
    c = Cookery.parse t

    checked = 0
    [:variable, :list_variable].each do |elem|
      message += "#{elem}" + "_" * (31 - elem.length) +
                 (c.captures.include?(elem) ?
                    c.captures[elem].map(&:inspect).join(", ").green : "") + "\n"
      if c.captures.include?(elem)
        checked += 1 if p[elem] == c.captures[elem].join(", ")
      end
    end

    {action_group: [:action, :action_arguments],
     subject_group: [:subject, :subject_arguments, :list_variable],
     condition_group: [:condition, :condition_arguments]}.each do |elem, names|
      names.each do |name|
        message += "#{name}" + "_" * (31 - name.length) +
             (c.captures.include?(elem) ?
                c.capture(elem)[name].map(&:inspect).join(", ").green : "") + "\n"
        if c.captures.include?(elem)
          if name == :list_variable
            checked += 1 if p[:list_variable_body] == c.capture(elem)[name].join(", ")
          else
            checked += 1 if p[name] == c.capture(elem)[name].join(", ")
          end
        end
      end
    end

    if not p[:skip] and not checked == p.length
      puts t.magenta
      puts "NOT MATCHING".red
      puts "it was suppose to be #{p.inspect}".red

      puts message
      p c.captures
      puts ("-" * 80).yellow
      next
    end

    counter += 1
  rescue Citrus::ParseError => e
    puts t.magenta
    puts "PARSING FAILD".red
    puts e.detail

    puts message
    puts ("-" * 80).yellow
  end
end

puts
puts "\t#{counter} / #{texts.length} passed".send(
       counter == texts.length ? :green :
         counter == 0 ? :red : :yellow)
puts
