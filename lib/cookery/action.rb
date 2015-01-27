class CookeryAction
  def initialize(name, &procedure)
    @name = name
    @procedure = procedure
  end

  def act(subject: nil, conditions: [], last_result: nil)
    if subject.nil?
      puts "in action #{@name}".blue
      if !last_result.nil?
        puts "in action #{@name} with last result #{last_result}".blue
      end
    else
      if last_result.nil?
        puts "in action #{@name} with subject #{subject}".blue
      else
        puts "in action #{@name} with subject #{subject} and last result #{last_result}".blue
      end
    end

    res = nil

    if subject.nil?
      res = instance_exec(last_result, &@procedure)
    else
      puts "acting on subject #{subject} of type #{subject.direction}".blue
      # hack to keep backwords compatible

      if subject.direction == :out
        conditions.each do |c|
          c.call(subject)
        end

        res = instance_exec(subject, last_result, &@procedure)
      else
        data = subject.get
        conditions.each do |c|
          data = c.call(data)
        end

        res = instance_exec(data, last_result, &@procedure)
      end
    end

    res
  end
end

Actions = Hash.new # { |h, k| h[k] = Hash.new }

def action(name, &procedure)
  if Actions.include? name
    warn "Action #{name} already exists, skipping".red
  else
    Actions[name] = CookeryAction.new(name, &procedure)
  end
end
