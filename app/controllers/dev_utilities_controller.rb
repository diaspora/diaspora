class DevUtilitiesController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include RequestsHelper
def warzombie
    render :nothing => true
    if current_user.email == "tom@tom.joindiaspora.com" && StatusMessage.where(:message => "There's a bomb in the lasagna!?").first == nil
      current_user.post(:status_message, :message => "There's a bomb in the lasagna!?") 
      current_user.post(:bookmark, :title => "xkcd", :link => "http://xkcd.com/743/" )
      current_user.post(:status_message, :message => "I switched to Motoroi today, a Motorola Android-based phone, in Korea. Now, I am using Android phones in both the U.S. and Korea", :created_at => Time.now-930)
      current_user.post(:status_message, :message => "I had 5 hours to study for it :-( GREs on Thursday. Wunderbar.", :created_at => Time.now-43990)
      current_user.post(:status_message, :message => "Spotted in toy story 3: google maps, OSX, and windows XP. Two out of three isn't bad.", :created_at => Time.now-4390)
      current_user.post(:bookmark,  :title => "Reddit", :link => "http://reddit.com", :created_at => Time.now-54390)
      current_user.post(:blog, :title => "I Love Rock'N'Roll - Joan Jett & The Blackhearts", :body => "<p>The loudspeakers played this song as we walked into the city pool for the first time this summer.  Those loudspeakers make every song sound fresh even if I have heard it a thousand times and their effect on this song was no different. Joan sounded young and strong and ready, and for a moment I forgot where or when I was.</p> <p>also i can tell it won’t be long and also happy summer imaginary constructs -mumblelard</p>", :created_at => Time.now-3090)  
      current_user.post(:status_message, :message => "Commercials for IE make me SO MAD and my friends just don't get why.", :created_at => Time.now-30900)
      current_user.post(:bookmark, :title => "Zombo.com", :link => "http://zombo.com", :created_at => Time.now-9090) 
      current_user.post(:status_message, :message => "Why do I have \"No More Heroes\" by Westlife on repeat all day?", :created_at => Time.now-590000)
      current_user.post(:status_message, :message => "Mmm. Friday night. Acknowledged.", :created_at => Time.now-503900)
      current_user.post(:status_message, :message => "Getting a universal remote is the epitome of laziness, I do declare.", :created_at => Time.now-4400)
      current_user.post(:status_message, :message => "Does anyone know how to merge two Skype contact entries of the same person? (i.e. one Skype ID and one mobile number)", :created_at => Time.now-400239)
      current_user.post(:status_message, :message => "A cool, cool morning for once.", :created_at => Time.now-150000)
    end
  end

  def zombiefriends
    render :nothing => true
    bkr_info  = backer_info

    if current_user.email == "tom@tom.joindiaspora.com" 
      bkr_info.each do |backer|
        backer_email = "#{backer['username']}@#{backer['username']}.joindiaspora.com"
        rel_hash = relationship_flow(backer_email)
        logger.info "Zombefriending #{backer['given_name']} #{backer['family_name']}"
        current_user.send_request(rel_hash, current_user.groups.first.id)
      end
    end
  end

  def zombiefriendaccept
    render :nothing => true
    Request.all.each{|r| 
      current_user.accept_friend_request(r.id, current_user.groups.first.id)
    }
  end

  def backer_info
    config = YAML.load_file(File.dirname(__FILE__) + '/../../config/deploy_config.yml') 
    config['servers']['backer']
  end

end
