# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

# Create seed user
user = User.create( :email => "robert@joindiaspora.com", :password => "monkey", :profile => Profile.new( :first_name => "bobert", :last_name => "brin" ))

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
          ["Abraham", "Lincoln"],
          ["Andrew", "Johnson"],
          ["Ulysses S.", "Grant"],
          ["Rutherford B.", "Hayes"],
          ["James A.", "Garfield"],
          ["Chester A.", "Arthur"],
          ["Grover", "Cleveland"],
          ["Benjamin", "Harrison"],
          ["William", "McKinley"],
          ["Theodore", "Roosevelt"],
          ["William Howard", "Taft"],
          ["Woodrow", "Wilson"],
          ["Warren G.", "Harding"],
          ["Calvin", "Coolidge"],
          ["Herbert", "Hoover"],
          ["Franklin D.", "Roosevelt"],
          ["Harry S.", "Truman"],
          ["Dwight D.", "Eisenhower"],
          ["John F.", "Kennedy"],
          ["Lyndon B.", "Johnson"],
          ["Richard", "Nixon"]
        ]

# Make people
(0..10).each { |n|
  username = names[n][1].gsub(/ /,'').downcase
  Person.create( :email => "#{username}@#{username}joindiaspora.com", :url => "http://#{username}.joindiaspora.com/", :active => true, :profile => Profile.new(:first_name => names[n][0], :last_name => names[n][1]))
}


