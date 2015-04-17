Subjects = Hash.new

def subject(name, arguments, protocol, &block)
  protocol_class = "#{protocol.capitalize}Protocol".safe_constantize

  if protocol_class.nil?
    warn "no such protocol: #{protocol}".red
  elsif protocol_class.superclass == CookeryProtocol
    Subjects[name] = protocol_class.new(name, arguments, &block)
  end
end
