#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

def create


  config = YAML.load_file(File.dirname(__FILE__) + '/../../config/deploy_config.yml')
  backer_info = config['servers']['backer']

  backer_number = YAML.load_file(Rails.root.join('config','backer_number.yml'))[:seed_number].to_i

  #set pod url
  username = backer_info[backer_number]['username'].gsub(/ /,'').downcase
  set_app_config username
  require 'config/initializers/_load_app_config.rb'

  # Create seed user
  user = User.instantiate!(:email => "#{username}@#{username}.joindiaspora.com",
                     :username => username,
                     :password => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :password_confirmation => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :person => Person.new(
                       :profile => Profile.new( :first_name => backer_info[backer_number]['given_name'], :last_name => backer_info[backer_number]['family_name'],
                                             :image_url => "http://#{username}.joindiaspora.com/images/user/#{username}.jpg")
                    ))
  user.person.save!

  user.aspect(:name => "Presidents")
end

def set_app_config username
  current_config = YAML.load(Rails.root.join('config', 'app_config.yml')).symbolize_keys
  current_config[Rails.env] ||= {}
  current_config[Rails.env][:pod_url] = "#{username}.joindiaspora.com"
  current_config[:default][:pod_url] = "#{username}.joindiaspora.com"
  file = File.new(Rails.root.join('config','app_config.yml'),'w')
  file.write(current_config.to_yaml)
  file.close
end
