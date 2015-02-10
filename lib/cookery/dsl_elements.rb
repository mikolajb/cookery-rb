# Helper method used in Cookery grammar.

def add_node(node)
  Cookery::MODULES.last.send("add_#{node.type}".to_sym, node)
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

  attr_accessor :variables, :state, :config

  def initialize(name, config = nil)
    @name = name
    @state = nil
    @variables = Hash.new
    @config = config
  end

  def method_missing(method, *args)
    if /add_(?<element_id>import|activity)/ =~ method
      (instance_variable_get('@' + element_id.pluralize) ||
       instance_variable_set('@' + element_id.pluralize, Array.new)) <<
        args.first
    elsif /add_(?<element_id>[[:alnum:]_-]+)/ =~ method
      # p element_id, args
      @activities.last.send("add_#{element_id}", *args)
    else
      throw NoMethodError.new("No method #{method} in CookeryModule")
    end
  end

  def evaluate(value)
    @state = value
    puts "Evaluate module with starting value: ".black_on_green +
         " #{value.inspect} ".black_on_magenta
    @activities.each do |a|
      a.evaluate(self)
      puts "Debug variables ".black_on_green +
           " #{@variables.inspect} ".black_on_magenta +
           " and state ".black_on_green +
           " #{@state.inspect} ".black_on_magenta
    end
    @state
  end
end

# This class represents one acticity in Cookery syntax (one sentence).

class Activity
  include Printer

  def type; :activity end

  def evaluate(c_module)
    puts "Evaluate activity ".black_on_green
    # print

    if !@action
      warn "no action to evaluate".red
      return
    end

    action_impl = Actions[@action.params[:name]]
    action_impl.config = c_module.config[:actions][@action.params[:name].to_sym]

    if @list_variable
      puts "There is list variable ".black_on_green +
           " #{@variable.inspect} ".black_on_magenta
      warn "List variables are not supported".red
      return
    end

    variables_in_activity = (@subjects || []).reject { |s|
      !c_module.variables.keys.include?(s.params[:name]) }
    subjects_in_activity = (@subjects || []).reject { |s|
      c_module.variables.keys.include?(s.params[:name]) }

    # check if the subjects and action are comatible
    unless subjects_in_activity.all? { |s|
        Subjects[s.params[:name]].type?(action_impl.type) } or
           subjects_in_activity.all? { |s|
        Subjects[s.params[:name]].type?(action_impl.type) }
      warn "Subjects incompatible with action".red
    end

    result = @subjects.map do |s|
      single_res = nil
      if subjects_in_activity.include?(s)
        puts "Argument is a subject".black_on_magenta
        subj_implementation = Subjects[s.params[:name]]
        puts "Evaluating subject ".black_on_green +
             " #{Subjects[s.params[:name]]} ".black_on_magenta
        single_res = Subjects[s.params[:name]].args(s.params[:arguments])

        puts "Evaluating action: ".black_on_green +
             " #{@action.params[:name]} ".black_on_magenta
        single_res = action_impl.process(single_res, @action.params[:arguments])

        if @conditions.nil? or @conditions.empty?
        else
          single_res = @conditions.inject(single_res) do |memo, c|
            Conditions[c.params[:name]].execute(memo, c.params[:arguments])
          end
        end
      else
        puts "Argument is a variable".black_on_magenta
        single_res = action_impl.process(c_module.variables[s.params[:name]],
                                         @action.params[:arguments])
      end

      single_res
    end if !@subjects.nil?

    if @subjects.nil?
      puts "Evaluating action: ".black_on_green +
           " #{@action.params[:name]} ".black_on_magenta
      p @action.params
      result = action_impl.process(c_module.state,
                                   @action.params[:arguments])
    end

    c_module.state = result
    if @variable
      c_module.variables[@variable.params[:name]] = result
      puts "Result saved in variable ".black_on_green +
           " #{@variable.params[:name]} ".black_on_magenta
    end
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
    elsif /add_(?<element_id>(?:list_subject|subject|condition|action))/ \
          =~ method
      warn "wrong number of arguments".red if args.length != 1

      (instance_variable_get('@' + element_id.pluralize) ||
       instance_variable_set('@' + element_id.pluralize, Array.new)) <<
        args.first
    else
      throw NoMethodError.new("No method #{method} in Activity")
    end
  end
end
