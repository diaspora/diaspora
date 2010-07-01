# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

# Create seed user
user = User.create( :email => "tom@joindiaspora.com", :password => "aaaaaa", :profile => Profile.create( :first_name => "Diaspora", :last_name => "Tom" ))

names = [ ["George", "Washington"],
          ["John", "Adams"],
          ["Thomas", "Jefferson"],
          ["James", "Madison"],
          ["James", "Monroe"],
          ["John Quincy", "Adams"],
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

# Make friends
(0..9).each { |n|
  Friend.create( :email => "#{names[n][1]}@joindiaspora.com", :url => "http://#{names[n][1]}.joindiaspora.com/", :profile => Profile.create(:first_name => names[n][0], :last_name => names[n][1]))
}

# Populate feed
#EventMachine::run{
  StatusMessage.create(:message => "There's a bomb in the lasagna!?", :person => user) 
  Bookmark.create(:title => "xkcd", :link => "http://xkcd.com/743/", :person => user )
  StatusMessage.create(:message => "I switched to Motoroi today, a Motorola Android-based phone, in Korea. Now, I am using Android phones in both the U.S. and Korea", :person => user, :created_at => Time.now-930)
  StatusMessage.create(:message => "I had 5 hours to study for it :-( GREs on Thursday. Wunderbar.", :person => user, :created_at => Time.now-43990)
  StatusMessage.create(:message => "Spotted in toy story 3: google maps, OSX, and windows XP. Two out of three isn't bad.", :person => user, :created_at => Time.now-4390)
  Bookmark.create( :title => "Reddit", :link => "http://reddit.com", :person => user, :created_at => Time.now-54390)
  Blog.create(:title => "I Love Rock'N'Roll - Joan Jett & The Blackhearts", :body => "<p>The loudspeakers played this song as we walked into the city pool for the first time this summer.  Those loudspeakers make every song sound fresh even if I have heard it a thousand times and their effect on this song was no different. Joan sounded young and strong and ready, and for a moment I forgot where or when I was.</p> <p>also i can tell it won’t be long and also happy summer imaginary constructs -mumblelard</p>", :person => user, :created_at => Time.now-3090)  
  StatusMessage.create(:message => "Commercials for IE make me SO MAD and my friends just don't get why.", :person => user, :created_at => Time.now-30900)
  Bookmark.create(:title => "Zombo.com", :link => "http://zombo.com", :person => user, :created_at => Time.now-9090) 
  StatusMessage.create(:message => "Why do I have \"No More Heroes\" by Westlife on repeat all day?", :person => user, :created_at => Time.now-590000)
  StatusMessage.create(:message => "Mmm. Friday night. Acknowledged.", :person => user, :created_at => Time.now-503900)
  StatusMessage.create(:message => "Getting a universal remote is the epitome of laziness, I do declare.", :person => user, :created_at => Time.now-4400)
  StatusMessage.create(:message => "Does anyone know how to merge two Skype contact entries of the same person? (i.e. one Skype ID and one mobile number)", :person => user, :created_at => Time.now-400240)
  StatusMessage.create(:message => "A cool, cool morning for once.", :person => user, :created_at => Time.now-150000)

#  EventMachine::stop
#}
