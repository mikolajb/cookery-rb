# Helper method used in Cookery grammar.

def add_node(node)
  puts "adding #{node.type}"
  Cookery::MODULES.last.send("add_#{node.type}".to_sym, node)
end

# Helper method used to handle input files contating source code of
# Cookery langauge.

def new_file(file)
  Cookery::MODULES << CookeryModule.new(file)

  implementation = File.absolute_path(
    File.join(File.dirname(file),
              File.basename(file, File.extname(file)) + '.rb'))

  if File.exist? implementation
    require implementation
  end
end

# Node handles all elements of Cookery language (e.g., actions,
# subjects, etc).

class Node
  include Printer
  attr_reader :type, :params

  def initialize(type)
    @type = type
    @params = {}
  end

  def set(param_name, value)
    @params[param_name] = value
  end
end

# CookeryModule is a class that handles one input file with a source
# code of Cookery language.

class CookeryModule
  include Printer

  def initialize(path)
    @path = path
  end

  def method_missing(method, *args)
    if /add_(?<element_id>import|activity)/ =~ method
      (instance_variable_get('@' + element_id.pluralize) ||
       instance_variable_set('@' + element_id.pluralize, Array.new)) <<
        args.first
    elsif /add_(?<element_id>[[:alnum:]_-]+)/ =~ method
      p element_id, args
      @activities.last.send("add_#{element_id}", *args)
    else
      throw NoMethodError.new("No method #{method} in CookeryModule")
    end
  end

  def evaluate
    puts " evaluate module ".black_on_magenta
    @activities.each { |a| a.evaluate(self) }
  end
end

# This class represents one acticity in Cookery syntax (one sentence).

class Activity
  include Printer

  def type; :activity end

  def evaluate(c_module)
    puts " evaluate activity ".black_on_yellow
    print

    if !@action
      warn "no action to evaluate".red
      return
    end

    puts "Evaluating action: #{@action.params[:name]}".black_on_green
    Actions[@action.params[:name]].act
    @subjects.map { |s| p s; Subjects[s.params[:name]] }
  end

  def method_missing(method, *args)
    if /add_(?<element_id>(?:list_)?variable)/ =~ method
      warn "too many arguments".red if args.length != 1
      if @variable
        warn "Terrible mistake, there is a variable already".red
        @variable.print
      end

      @variable = args.first
      @variable.set(:type, element_id.to_sym)
    elsif :add_action == method
      if @action
        warn "Terrible mistake, there is an action already".red
        @action.print
      end
      @action = args.first
    elsif /add_(?<element_id>(?:list_subject|subject|condition|action))/ =~ method
      warn "wrong number of arguments".red if args.length != 1

      (instance_variable_get('@' + element_id.pluralize) ||
       instance_variable_set('@' + element_id.pluralize, Array.new)) <<
        args.first
    else
      throw NoMethodError.new("No method #{method} in Activity")
    end
  end
end
