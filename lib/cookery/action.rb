class CookeryAction
  attr_accessor :type

  def initialize(name, type, &procedure)
    @name = name
    @type = type
    @procedure = procedure
  end

  def process(data)
    instance_exec(data, &@procedure)
  end

  def act(subject: nil, conditions: [], last_result: nil)
    if subject.nil?
      puts "In action #{@name}"
      if !last_result.nil?
        puts "in action #{@name} with last result #{last_result}"
      end
    else
      if last_result.nil?
        puts "in action #{@name} with subject #{subject}"
      else
        puts "in action #{@name} with subject #{subject} and last result #{last_result}"
      end
    end

    res = nil

    if subject.nil?
      res = instance_exec(last_result, &@procedure)
    else
      puts "acting on subject #{subject} of type #{subject.type}".blue
      # hack to keep backwords compatible

      if subject.type == :out
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

def action(name, type, &procedure)
  if Actions.include? name
    warn "Action #{name} already exists, skipping".red
  else
    Actions[name] = CookeryAction.new(name, type, &procedure)
  end
end

action("test", :out) do |data|
  puts "Just a test, passing data from subject"
  data
end
