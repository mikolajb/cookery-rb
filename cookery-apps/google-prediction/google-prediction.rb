action("load", :in) do |sbj|
  sbj.get
end

action("google-prediction", :out) do |data, args, config|
  require 'google/api_client'
  require 'json'

  key = Google::APIClient::KeyUtils.load_from_pkcs12('Cookery-b3fe9aee9315.p12',
                                                    'notasecret')
  auth_client = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :scope => 'https://www.googleapis.com/auth/prediction',
    :issuer => '1096242455363-n305c5bjqdm54e1e07rmu1fm8k4i43pu@developer.gserviceaccount.com',
    :signing_key => key)
  auth_client.fetch_access_token!

  client = Google::APIClient.new(:application_name => "Cookery",
                                 :application_version => "0.1")
  prediction = client.discovered_api('prediction', 'v1.6')
  results = []
  data = data.instance_of?(Array) ? data : [data]
  data.each do |d|
    result = client.execute(:api_method => prediction.trainedmodels.predict,
                            :parameters =>
                            {'id' => 'language-detection',
                             'project' => 'symbolic-button-852'},
                            :authorization => auth_client,
                            :headers => {'Content-Type' => 'application/json'},
                            :body => { "input": {"csvInstance": [d]}}.to_json)
    results << JSON.load(result.body)["outputLabel"]
  end
  results
end

action("test", :out) do |data|
  puts "Just a test, passing data from subject"
  data
end

subject("Test", nil, "test") do
  "fake result".bytes.map { |i| (i >= 97 and i <= 122 and rand > 0.5) ?
                              i - 32 : i }.pack("c*")
end

subject("File", /(.+)/, "file") do |args|
  puts "FILE"
  p args
end

subject("RemoteFile", /(.+)/, "http") do |args|
  puts "REMOTE FILE"
  url args
  p args
end
