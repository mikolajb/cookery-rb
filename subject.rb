require 'active_support/all'

class CookeryProtocol
end

class FileProtocol < CookeryProtocol
  attr_accessor :name, :arguments

  def initialize(name, arguments, &block)
    @name = /#{name}/
    @arguments = arguments
    @block = block
  end

  def path(path)
    @path = path
  end

  def args(*arguments)
    instance_exec(*arguments, &@block)
  end

  def get
    open(@path).read()
  end
end

Subjects = Hash.new

def subject(name, arguments, protocol, &block)
  protocol_class = "#{protocol.capitalize}Protocol".safe_constantize

  if protocol_class.nil?
    warn "no such protocol: #{protocol}"
  elsif protocol_class.superclass == CookeryProtocol
    Subjects[name] = protocol_class.new(name, arguments, &block)
  end
end
