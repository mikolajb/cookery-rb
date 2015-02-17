require 'rest_client'

class CookeryProtocol
  attr_accessor :name, :arguments

  def self.type(*dir)
    class_variable_set(:@@type, dir)
  end

  def type
    self.class.class_variable_get(:@@type)
  end

  def type?(potential_type)
    type.include?(potential_type)
  end

  def initialize(name, arguments, &block)
    @name = name
    @arguments = arguments
    @block = block
  end

  def to_s
    "#{@name} #{@arguments.inspect}"
  end

  def args(arguments)
    if @arguments
      instance_exec(*@arguments.match(arguments).captures, &@block)
    else
      instance_exec(&@block)
    end
  end
end

class FileProtocol < CookeryProtocol
  type :in, :out

  def path(path)
    @path = path
  end

  def get
    open(@path).read()
  end
end

class HttpProtocol < CookeryProtocol
  type :out

  def url(url)
    puts "setting url #{url}".blue
    @url = url
  end

  def put(parameters)
    RestClient.put @url, parameters
  end

  def test
    puts "test ok".blue
  end
end

class TestProtocol < CookeryProtocol
  type :out
end

Subjects = Hash.new

def subject(name, arguments, protocol, &block)
  protocol_class = "#{protocol.capitalize}Protocol".safe_constantize

  if protocol_class.nil?
    warn "no such protocol: #{protocol}".red
  elsif protocol_class.superclass == CookeryProtocol
    Subjects[name] = protocol_class.new(name, arguments, &block)
  end
end
