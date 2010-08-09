# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

def create(backer_number)
  config = YAML.load_file(File.dirname(__FILE__) + '/../../config/deploy_config.yml') 
  backer_info = config['servers']['backer']


  # Create seed user
  username = backer_info[backer_number]['username'].gsub(/ /,'').downcase
  user = User.create( :email => "#{username}@#{username}.joindiaspora.com",
                     :password => "#{username+backer_info[backer_number]['pin'].to_s}",
                     :person => Person.new(
                       :email => "#{username}@#{username}.joindiaspora.com",
                       :profile => Profile.new( :first_name => backer_info[backer_number]['given_name'], :last_name => backer_info[backer_number]['family_name'] ),
                       :url=> "http://#{username}.joindiaspora.com/")
                    )
  user.person.save
end

