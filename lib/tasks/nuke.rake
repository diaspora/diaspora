require 'heroku-api'
task :nuke_workers do
  api = Heroku::API.new #ENV['HEROKU_API_KEY']
  api.post_ps_restart('diaspora-production')
end
