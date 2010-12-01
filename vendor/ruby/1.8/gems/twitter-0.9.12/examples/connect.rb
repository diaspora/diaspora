require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
require File.join(File.dirname(__FILE__), 'helpers', 'config_store')
require 'pp'

config = ConfigStore.new("#{ENV['HOME']}/.twitter")
oauth = Twitter::OAuth.new(config['token'], config['secret'])

if config['atoken'] && config['asecret']
  oauth.authorize_from_access(config['atoken'], config['asecret'])
  twitter = Twitter::Base.new(oauth)
  pp twitter.friends_timeline

elsif config['rtoken'] && config['rsecret']
  oauth.authorize_from_request(config['rtoken'], config['rsecret'], 'PIN')
  twitter = Twitter::Base.new(oauth)
  pp twitter.friends_timeline

  config.update({
    'atoken'  => oauth.access_token.token,
    'asecret' => oauth.access_token.secret,
  }).delete('rtoken', 'rsecret')
else
  config.update({
    'rtoken'  => oauth.request_token.token,
    'rsecret' => oauth.request_token.secret,
  })

  # authorize in browser
  %x(open #{oauth.request_token.authorize_url})
end
