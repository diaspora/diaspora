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
  pin =[5072,
        3742,
        7782,
        2691,
        6133,
        7558,
        8670,
        1559,
        5404,
        6431,
        1957,
        5323,
        8784,
        4267,
        8891,
        2324,
        6948,
        8176,
        6928,
        5677,
        7966,
        2893,
        6828,
        2982,
        6756,
        6658,
        3551,
        3088,
        8379,
        7493,
        2759,
        1029,
        4013,
        8507,
        1508,
        5258]

  # Create seed user
  email = names[backer_number][1].gsub(/ /,'').downcase
  user = User.create( :email => "#{email}@joindiaspora.com", :password => "#{email+pin[backer_number].to_s}", :profile => Profile.create( :first_name => names[backer_number][0], :last_name => names[backer_number][1] ))

  # Make friends with Diaspora Tom
  Friend.create( :email => "tom@joindiaspora.com", :url => "http://tom.joindiaspora.com/", :profile => Profile.create(:first_name => "Diaspora", :last_name => "Tom"))
  # Make friends
  
  (0..10).each { |n|
    email = names[n][1].gsub(/ /,'').downcase
    Friend.create( :email => "#{email}@joindiaspora.com", :url => "http://#{email}.joindiaspora.com/", :profile => Profile.create(:first_name => names[n][0], :last_name => names[n][1])) unless n == backer_number
  }
end

