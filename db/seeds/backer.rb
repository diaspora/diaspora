# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'



def create(backer_number, password)
  backer_info = [ [5072,"George", "Washington"],
                  [3742,"John", "Adams"],
                  [7782,"Thomas", "Jefferson"],
                  [2691,"James", "Madison"],
                  [6133,"James", "Monroe"],
                  [7558,"John", "Quincy Adams"],
                  [8670,"Andrew", "Jackson"],
                  [1559,"Martin Van", "Buren"],
                  [5404,"William Henry","Harrison"],
                  [6431,"John", "Tyler"],
                  [1957,"James K." , "Polk"],
                  [5323,"Zachary", "Taylor"],
                  [8784,"Millard", "Fillmore"],
                  [4267,"Franklin", "Pierce"],
                  [8891,"James", "Buchanan"],
                  [2324,"Abraham", "Lincoln"],
                  [6948,"Andrew", "Johnson"],
                  [8176,"Ulysses S.", "Grant"],
                  [6928,"Rutherford B.", "Hayes"],
                  [5677,"James A.", "Garfield"],
                  [7966,"Chester A.", "Arthur"],
                  [2893,"Grover", "Cleveland"],
                  [6828,"Benjamin", "Harrison"],
                  [2982,"William", "McKinley"],
                  [6756,"Theodore", "Roosevelt"],
                  [6658,"William Howard", "Taft"],
                  [3551,"Woodrow", "Wilson"],
                  [3088,"Warren G.", "Harding"],
                  [8379,"Calvin", "Coolidge"],
                  [7493,"Herbert", "Hoover"],
                  [2759,"Franklin D.", "Roosevelt"],
                  [1029,"Harry S.", "Truman"],
                  [4013,"Dwight D.", "Eisenhower"],
                  [8507,"John F.", "Kennedy"],
                  [1508,"Lyndon B.", "Johnson"],
                  [5258,"Richard", "Nixon"]
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
  email = backer_info[backer_number][2].gsub(/ /,'').downcase
  user = User.create( :email => "#{email}@joindiaspora.com", :password => "#{email+backer_info[backer_number][0].to_s}", :profile => Profile.create( :first_name => backer_info[backer_number][1], :last_name => backer_info[backer_number][2] ))

  # Make friends with Diaspora Tom
  Friend.create( :email => "tom@joindiaspora.com", :url => "http://tom.joindiaspora.com/", :profile => Profile.create(:first_name => "Alexander", :last_name => "Hamiltom"))
  # Make friends
  
  (0..10).each { |n|
    email = backer_info[n][2].gsub(/ /,'').downcase
    Friend.create( :email => "#{email}@joindiaspora.com", :url => "http://#{email}.joindiaspora.com/", :profile => Profile.create(:first_name => backer_info[n][1], :last_name => backer_info[n][2])) unless n == backer_number
  }
end

