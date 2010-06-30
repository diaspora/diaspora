# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

# Create seed user
User.create( :email => "a@a.com", :password => "aaaaaa", :profile => Profile.create( :first_name => "Robert", :last_name => "Grimm" ))

# Make friends
friend_one = Friend.create( :email => "babycakes@a.com", :url => "http://babycakes.joindiaspora.com/", :profile =>Profile.create( :first_name => "Baby", :last_name => "Cakes") )
friend_two = Friend.create( :email => "mario@a.com", :url => "http://mario.joindiaspora.com/",  :profile => Profile.create( :first_name => "Mario", :last_name => "Cakes") )
friend_three = Friend.create( :email => "stuff@a.com", :url => "http://stuff.joindiaspora.com/",  :profile => Profile.create( :first_name => "Stuff", :last_name => "Cakes") )

# Populate feed
StatusMessage.create(:message => "There's a bomb in the lasagna!?", :person => friend_one )

Bookmark.create(:title => "xkcd", :link => "http://xkcd.com/743/", :person => friend_two )

StatusMessage.create(:message => "I switched to Motoroi today, a Motorola Android-based phone, in Korea. Now, I am using Android phones in both the U.S. and Korea", :person => friend_two )

StatusMessage.create(:message => "I had 5 hours to study for it :-( GREs on Thursday. Wunderbar.", :person => friend_two )

StatusMessage.create(:message => "Spotted in toy story 3: google maps, OSX, and windows XP. Two out of three isn't bad.", :person => friend_three )

Bookmark.create( :title => "Reddit", :link => "http://reddit.com", :person => friend_one )
Blog.create(:title => "I Love Rock'N'Roll - Joan Jett & The Blackhearts", :body => "<p>The loudspeakers played this song as we walked into the city pool for the first time this summer.  Those loudspeakers make every song sound fresh even if I have heard it a thousand times and their effect on this song was no different. Joan sounded young and strong and ready, and for a moment I forgot where or when I was.</p> <p>also i can tell it won’t be long and also happy summer imaginary constructs -mumblelard</p>", :person => friend_one )


StatusMessage.create(:message => "Commercials for IE make me SO MAD and my friends just don't get why.", :person => friend_one )
Bookmark.create(:title => "Zombo.com", :link => "http://zombo.com", :person => friend_three )

StatusMessage.create(:message => "Why do I have \"No More Heroes\" by Westlife on repeat all day?", :person => friend_two )
StatusMessage.create(:message => "Mmm. Friday night. Acknowledged.", :person => friend_three )

StatusMessage.create(:message => "Getting a universal remote is the epitome of laziness, I do declare.", :person => friend_one )

StatusMessage.create(:message => "Does anyone know how to merge two Skype contact entries of the same person? (i.e. one Skype ID and one mobile number)", :person => friend_two )
StatusMessage.create(:message => "A cool, cool morning for once.", :person => friend_one )
