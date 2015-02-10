require 'mail'

action('create-email', :out) do |s, args|
  Mail.new do
    to args['to']
    from args['from']
    subject args['subject']
    body args['body']
  end
end

action('send', :out) do |s, args, config|
  s.delivery_method(:smtp,
                    {:enable_starttls_auto => true}.merge(
                      config.symbolize_keys.select { |k, v|
                        [:address,
                         :port,
                         :domain,
                         :user_name,
                         :password,
                         :authentication].include?(k) }))
end


