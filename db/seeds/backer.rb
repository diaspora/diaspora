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
                     :profile => Profile.new( :first_name => backer_info[backer_number]['given_name'], :last_name => backer_info[backer_number]['family_name'] ),
                    :url=> "#{username}.joindiaspora.com")

  # Make connection with Diaspora Tom
  #Person.create( :email => "tom@joindiaspora.com", :url => "http://tom.joindiaspora.com/", :active => true, :profile => Profile.new(:first_name => "Alexander", :last_name => "Hamiltom"))
  # Make people
  
#  (0..10).each { |n|
    #domain_name = backer_info[n][2].gsub(/ /,'').downcase
    #url = "http://#{domain_name}.joindiaspora.com/"
    #User.owner.send_friend_request_to(url)
  #}
end

