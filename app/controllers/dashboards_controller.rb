class DashboardsController < ApplicationController
  
  before_filter :authenticate_user!, :except => :receive
  include ApplicationHelper

  def index
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def receive
    puts "SOMEONE JUST SENT ME: #{params[:xml]}"
    store_objects_from_xml params[:xml]
    render :nothing => true
  end
  
  
  def warzombie
    render :nothing => true
    if User.owner.email == "tom@joindiaspora.com" && StatusMessage.where(:message => "There's a bomb in the lasagna!?").first == nil
      StatusMessage.create(:message => "There's a bomb in the lasagna!?", :person => User.owner) 
      Bookmark.create(:title => "xkcd", :link => "http://xkcd.com/743/", :person => User.owner )
      StatusMessage.create(:message => "I switched to Motoroi today, a Motorola Android-based phone, in Korea. Now, I am using Android phones in both the U.S. and Korea", :person => User.owner, :created_at => Time.now-930)
      StatusMessage.create(:message => "I had 5 hours to study for it :-( GREs on Thursday. Wunderbar.", :person => User.owner, :created_at => Time.now-43990)
      StatusMessage.create(:message => "Spotted in toy story 3: google maps, OSX, and windows XP. Two out of three isn't bad.", :person => User.owner, :created_at => Time.now-4390)
      Bookmark.create( :title => "Reddit", :link => "http://reddit.com", :person => User.owner, :created_at => Time.now-54390)
      Blog.create(:title => "I Love Rock'N'Roll - Joan Jett & The Blackhearts", :body => "<p>The loudspeakers played this song as we walked into the city pool for the first time this summer.  Those loudspeakers make every song sound fresh even if I have heard it a thousand times and their effect on this song was no different. Joan sounded young and strong and ready, and for a moment I forgot where or when I was.</p> <p>also i can tell it won’t be long and also happy summer imaginary constructs -mumblelard</p>", :person => User.owner, :created_at => Time.now-3090)  
      StatusMessage.create(:message => "Commercials for IE make me SO MAD and my friends just don't get why.", :person => User.owner, :created_at => Time.now-30900)
      Bookmark.create(:title => "Zombo.com", :link => "http://zombo.com", :person => User.owner, :created_at => Time.now-9090) 
      StatusMessage.create(:message => "Why do I have \"No More Heroes\" by Westlife on repeat all day?", :person => User.owner, :created_at => Time.now-590000)
      StatusMessage.create(:message => "Mmm. Friday night. Acknowledged.", :person => User.owner, :created_at => Time.now-503900)
      StatusMessage.create(:message => "Getting a universal remote is the epitome of laziness, I do declare.", :person => User.owner, :created_at => Time.now-4400)
      StatusMessage.create(:message => "Does anyone know how to merge two Skype contact entries of the same person? (i.e. one Skype ID and one mobile number)", :person => User.owner, :created_at => Time.now-400239)
      StatusMessage.create(:message => "A cool, cool morning for once.", :person => User.owner, :created_at => Time.now-150000)
    end
  end

  def zombiefriends
    render :nothing => true
    backer_info = ["http://washington.joindiaspora.com",
                   "http://adams.joindiaspora.com",
                   "http://jefferson.joindiaspora.com",
                   "http://madison.joindiaspora.com",
                   "http://monroe.joindiaspora.com",
                   "http://quincyadams.joindiaspora.com",
                   "http://jackson.joindiaspora.com",
                   "http://buren.joindiaspora.com",
                   "http://harrison.joindiaspora.com",
                   "http://tyler.joindiaspora.com",
                   "http://polk.joindiaspora.com",
                   #"http://taylor.joindiaspora.com",
                   #"http://fillmore.joindiaspora.com",
                   #"http://pierce.joindiaspora.com",
            ]

    if User.owner.email == "tom@joindiaspora.com" && StatusMessage.where(:message => "There's a bomb in the lasagna!?").first == nil
      backer_info.each do |backer|
        logger.info backer
        User.owner.send_friend_request_to(backer)
      end
    end
  end
end
