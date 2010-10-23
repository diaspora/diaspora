#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

def create

  config = YAML.load_file(File.join(File.dirname(__FILE__), "..", "..", "config", "deploy_config.yml"))
  backer_info = config['servers']['backer']

  backer_number = YAML.load_file(Rails.root.join('config','backer_number.yml'))[:seed_number].to_i

  #set pod url
  username = backer_info[backer_number]['username'].gsub(/ /,'').downcase
  set_app_config username unless File.exists?(Rails.root.join('config', 'app_config.yml'))

  require File.join(File.dirname(__FILE__), "..", "..", "config", "initializers", "_load_app_config.rb")

  # Create seed user
  user = User.build(:email => "#{username}@#{username}.joindiaspora.com",
                     :username => username,
                     :password => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :password_confirmation => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :person => Person.new(
                       :profile => Profile.new( :first_name => backer_info[backer_number]['given_name'], :last_name => backer_info[backer_number]['family_name'],
                                             :image_url => "http://#{username}.joindiaspora.com/images/user/#{username}.jpg")
                    ))
  user.save
  user.person.save!

  user.aspect(:name => "Presidents")
end

def set_app_config username
  current_config = YAML.load(File.read(Rails.root.join('config', 'app_config.yml.example')))
  current_config[Rails.env.to_s] ||= {}
  current_config[Rails.env.to_s]['pod_url'] = "http://#{username}.joindiaspora.com/"
  current_config['default']['pod_url'] = "http://#{username}.joindiaspora.com/"
  file = File.new(Rails.root.join('..','..','shared','app_config.yml'),'w')
  file.write(current_config.to_yaml)
  file.close
end
