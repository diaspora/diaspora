# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
#
require File.join(Rails.root, 'lib', 'enviroment_configuration')

namespace :heroku do
  HEROKU_CONFIG_ADD_COMMAND = "heroku config:add HEROKU=true"

  task :config do
    puts "Reading config/application.yml and sending config vars to Heroku..."
    application_config = YAML.load_file('config/application.yml')['production'] rescue {}
    application_config.delete_if { |k, v| v.blank? }

    heroku_env = application_config.map do|key, value| 
      value =value.join(EnviromentConfiguration::ARRAY_SEPERATOR) if value.respond_to?(:join)

      "#{key}=#{value}"
    end.join(' ')

    puts "Generating and setting a new secret token"
    token = ActiveSupport::SecureRandom.hex(40)#reloads secret token every time you reload vars.... this expires cookies, and kinda sucks
    system "#{HEROKU_CONFIG_ADD_COMMAND} #{heroku_env} SECRET_TOKEN=#{token}"
  end

  task :install_requirements do
    system 'heroku addons:add lgging:expanded'
    system 'heroku addons:add redistogo:nano'
  end
end
