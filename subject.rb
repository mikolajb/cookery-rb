require 'active_support/all'

class CookeryProtocol
end

class FileProtocol < CookeryProtocol
  attr_accessor :name, :arguments

  def initialize(name, arguments, &block)
    @name = /#{name}/
    @arguments = arguments
    instance_eval(&block)
  end

  def path(path)
    puts "path: #{path}"
    @path = path
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
