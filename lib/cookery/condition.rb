class CookeryCondition
  def initialize(name, arguments, &block)
    @name = name
    @arguments = arguments
    @block = block
  end

  def execute(data, arguments)
    instance_exec(data, *@arguments.match(arguments).captures, &@block)
  end
end

Conditions = Hash.new

def condition(name, arguments, &block)
  Conditions[name] = CookeryCondition.new(name, arguments, &block)
end
