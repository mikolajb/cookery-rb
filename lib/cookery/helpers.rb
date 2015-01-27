module Printer
  INC_INDENT = "  "

  def print indent = ""
    puts "#{indent}#{self.class} #{type if self.respond_to? :type}".yellow
    instance_variables.each do |v|
      puts "#{indent}#{v}:".magenta
      elem = instance_variable_get(v)
      if elem.instance_of? Array
        elem.each do |e|
          if e.respond_to? :print
            e.print(indent + INC_INDENT)
          else
            puts "#{indent}#{e.inspect}".blue
          end
        end
      else
        if elem.respond_to? :print
          elem.print(indent + INC_INDENT)
        else
          puts "#{indent}#{elem.inspect}".blue
        end
      end
    end
  end
end
