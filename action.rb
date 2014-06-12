
class CookeryAction
  def initialize(name, &procedure)
    @name = name
    @procedure = procedure
  end

  def act(*arguments)
    instance_exec(*arguments, &@procedure)
  end
end


Actions = Hash.new # { |h, k| h[k] = Hash.new }

def action(name, type = nil, &procedure)
  Actions[name] = CookeryAction.new(name, &procedure)
end
