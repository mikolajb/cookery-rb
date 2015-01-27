require 'active_support/all'
require 'rest_client'

class CookeryProtocol
  attr_accessor :name, :arguments

  def self.direction(dir)
    class_variable_set(:@@direction, dir)
  end

  def direction
    self.class.class_variable_get(:@@direction)
  end

  def initialize(name, arguments, &block)
    @name = /#{name}/
    @arguments = arguments
    @block = block
  end

  def to_s
    @name.to_s
  end

  def args(arguments)
    instance_exec(*@arguments.match(arguments).captures, &@block)
  end
end

class FileProtocol < CookeryProtocol
  direction :in

  def path(path)
    @path = path
  end

  def get
    open(@path).read()
  end
end

class HttpProtocol < CookeryProtocol
  direction :out

  def url(url)
    puts "setting url #{url}".blue
    @url = url
  end

  def put(parameters)
    RestClient.put @url, parameters
  end

  def test
    puts "test ok".blule
  end
end

Subjects = Hash.new

def subject(name, arguments, protocol, &block)
  puts "defining subject #{name}, #{arguments}, #{protocol}".blue

  protocol_class = "#{protocol.capitalize}Protocol".safe_constantize

  if protocol_class.nil?
    warn "no such protocol: #{protocol}".red
  elsif protocol_class.superclass == CookeryProtocol
    Subjects[name] = protocol_class.new(name, arguments, &block)
  end
end
