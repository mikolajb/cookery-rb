class CookeryAction
  def initialize(name, &procedure)
    @name = name
    @procedure = procedure
  end

  def act(subject: nil, conditions: [])
    if subject.nil?
      instance_eval(&@procedure)
    else
      data = subject.get
      conditions.each do |c|
        data = c.call(data)
      end
      instance_exec(data, &@procedure)
    end
  end
end

Actions = Hash.new # { |h, k| h[k] = Hash.new }

def action(name, &procedure)
  Actions[name] = CookeryAction.new(name, &procedure)
end
