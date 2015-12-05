action('create-email', :out) do |s, args|
  require 'mail'

  m = Mail.new do
    to args['to']
    from args['from']
    subject args['subject']
    part :content_type => 'text/plain', :body => args['body']
  end

  s.each_with_index do |i, ii|
    m.attachments["result#{ii}"] = {:mime_type => 'text/plain',
                                    :content => i}
  end
  m
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
  s.deliver
end
