# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'



def create(backer_number)
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


  # Create seed user
  email = backer_info[backer_number][2].gsub(/ /,'').downcase
  user = User.create( :email => "#{email}@joindiaspora.com",
                     :password => "#{email+backer_info[backer_number][0].to_s}",
                     :profile => Profile.create( :first_name => backer_info[backer_number][1], :last_name => backer_info[backer_number][2] ),
                    :url=> "#{email}.joindiaspora.com")

  # Make connection with Diaspora Tom
  Person.create( :email => "tom@joindiaspora.com", :url => "http://tom.joindiaspora.com/", :active => true, :profile => Profile.create(:first_name => "Alexander", :last_name => "Hamiltom"))
  # Make people
  
  (0..10).each { |n|
    email = backer_info[n][2].gsub(/ /,'').downcase
    Person.create( :email => "#{email}@joindiaspora.com", 
                  :url => "http://#{email}.joindiaspora.com/", 
                  :active => true, 
                  :profile => Profile.create(
                    :first_name => backer_info[n][1],
                    :last_name => backer_info[n][2]))  unless n == backer_number
  }
end

