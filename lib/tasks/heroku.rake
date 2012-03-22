 #Copyright (c) 2012, Diaspora Inc.  This file is
 #licensed under the Affero General Public License version 3 or later.  See
 #the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'enviroment_configuration')

namespace :heroku do
  HEROKU_CONFIG_ADD_COMMAND = "heroku config:add"

  task :generate_secret_token do
    puts "Generating and setting a new secret token"
    token = SecureRandom.hex(40)#reloads secret token every time you reload vars.... this expires cookies, and kinda sucks
    command = "#{HEROKU_CONFIG_ADD_COMMAND} SECRET_TOKEN=#{token}"
    puts command
    system command
  end

  task :install_requirements do
    system 'heroku addons:remove logging:basic'
    system 'heroku addons:add logging:expanded'
    system 'heroku addons:add redistogo:nano'
  end
end
