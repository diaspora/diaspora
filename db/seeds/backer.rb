# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'



def create(backer_number, password)
  names = [ ["George", "Washington"],
            ["John", "Adams"],
            ["Thomas", "Jefferson"],
            ["James", "Madison"],
            ["James", "Monroe"],
            ["John", "Quincy Adams"],
            ["Andrew", "Jackson"],
            ["Martin Van", "Buren"],
            ["William Henry","Harrison"],
            ["John", "Tyler"],
            ["James K." , "Polk"],
            ["Zachary", "Taylor"],
            ["Millard", "Fillmore"],
            ["Franklin", "Pierce"],
            ["James", "Buchanan"],
            ["Abraham", "Lincoln"]
          ]

  # Create seed user
  email = names[backer_number][1].gsub(/ /,'').downcaase
  user = User.create( :email => "#{email}@joindiaspora.com", :password => "#{password}", :profile => Profile.create( :first_name => names[backer_number][0], :last_name => names[backer_number][1] ))

  # Make friends with Diaspora Tom
  Friend.create( :email => "tom@joindiaspora.com", :url => "http://tom.joindiaspora.com/", :profile => Profile.create(:first_name => "Diaspora", :last_name => "Tom"))
  # Make friends
  
  (0..10).each { |n|
    email = names[n][1].gsub(/ /,'').downcaase
    Friend.create( :email => "#{email}@joindiaspora.com", :url => "http://#{email}.joindiaspora.com/", :profile => Profile.create(:first_name => names[n][0], :last_name => names[n][1])) unless n == backer_number
  }
end

