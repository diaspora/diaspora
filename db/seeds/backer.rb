#   Copyright (c) 2010, Disapora Inc.  This file is
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
  # Create seed user
  username = backer_info[backer_number]['username'].gsub(/ /,'').downcase
  user = User.create(:email => "#{username}@#{username}.joindiaspora.com",
                     :username => username,
                     :password => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :url=> "http://#{username}.joindiaspora.com/",
                     :person => Person.new(
                       :diaspora_handle => "#{username}@#{username}.joindiaspora.com",
                       :profile => Profile.new( :first_name => backer_info[backer_number]['given_name'], :last_name => backer_info[backer_number]['family_name'], 
                                             :image_url => "http://#{username}.joindiaspora.com/images/user/#{username}.jpg"),
                       :url=> "http://#{username}.joindiaspora.com/")
                    )
  user.person.save!

  user.aspect(:name => "Presidents")
end

