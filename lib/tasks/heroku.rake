 #Copyright (c) 2012, Diaspora Inc.  This file is
 #licensed under the Affero General Public License version 3 or later.  See
 #the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'enviroment_configuration')

namespace :heroku do
  HEROKU_CONFIG_ADD_COMMAND = "heroku config:add"

  task :generate_secret_token do
    puts "Generating and setting a new secret token"
    token = SecureRandom.hex(40) #reloads secret token every time you reload vars.... this expires cookies, and kinda sucks
    command = "#{HEROKU_CONFIG_ADD_COMMAND} SECRET_TOKEN=#{token}"
    puts command
    system command
  end

  task :install_requirements do
    system 'heroku addons:remove logging:basic'
    system 'heroku addons:add logging:expanded'
    system 'heroku addons:add redistogo:nano'
  end

  task :set_up_s3_sync => [:environment] do
    fog_provider = "FOG_PROVIDER=AWS"
    aws_access_key_id = "AWS_ACCESS_KEY_ID=#{AppConfig[:s3_key]}"
    aws_secret_access_key = "AWS_SECRET_ACCESS_KEY=#{AppConfig[:s3_secret]}"
    fog = "FOG_DIRECTORY=#{AppConfig[:s3_bucket]}"
    asset_host = "ASSET_HOST=https://#{AppConfig[:s3_bucket]}.s3.amazonaws.com"
    
    each_heroku_app do |stage|
      system("heroku labs:enable user_env_compile -a #{stage.app}")
      stage.run('config:add', "#{fog} #{fog_provider} #{aws_secret_access_key} #{aws_access_key_id} ASSET_HOST=#{asset_host}")
    end
  end
end