#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")
require File.join(File.dirname(__FILE__), "..", "..", "spec", "helper_methods")

def set_app_config username
  current_config = YAML.load(File.read(Rails.root.join('config', 'app_config.yml.example')))
  current_config[Rails.env.to_s] ||= {}
  current_config[Rails.env.to_s]['pod_url'] = "http://#{username}.joindiaspora.com/"
  current_config['default']['pod_url'] = "http://#{username}.joindiaspora.com/"
  file = File.new(Rails.root.join('..','..','shared','app_config.yml'),'w')
  file.write(current_config.to_yaml)
  file.close
end

set_app_config "tom" unless File.exists?(Rails.root.join('config', 'app_config.yml'))

require 'config/initializers/_load_app_config.rb'
include HelperMethods

# Create seed user
user = User.build( :email => "tom@tom.joindiaspora.com",
                     :username => "tom",
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                    :person => {
                      :profile => { :first_name => "Alexander", :last_name => "Hamiltom",
                      :image_url => "http://tom.joindiaspora.com/images/user/tom.jpg"}})
user.save!
user.seed_aspects
user.person.save!

user2 = User.build( :email => "korth@tom.joindiaspora.com",
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                     :username => "korth",
                    :person => {:profile => { :first_name => "Evan", :last_name => "Korth",
                      :image_url => "http://tom.joindiaspora.com/images/user/korth.jpg"}})
user2.save!
user2.seed_aspects
user2.person.save!
# friending users
aspect = user.aspect(:name => "other dudes") 
aspect2 = user2.aspect(:name => "presidents")

friend_users(user, aspect, user2, aspect2)
user.aspect(:name => "Presidents")
