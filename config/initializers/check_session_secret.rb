if AppConfig.heroku?
  Rails.application.config.secret_token = AppConfig.secret_token
elsif !File.exists?( Rails.root.join('config', 'initializers', 'secret_token.rb'))
  `bundle exec rake generate:secret_token`
  require  Rails.root.join('config', 'initializers', 'secret_token.rb')
end 
