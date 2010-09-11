class DevUtilitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [:set_backer_number]
  include ApplicationHelper
  include RequestsHelper
def warzombie
    render :nothing => true
    if current_user.email == "tom@tom.joindiaspora.com" && StatusMessage.where(:message => "There's a bomb in the lasagna!?").first == nil
      current_user.post(:status_message, :message => "There's a bomb in the lasagna!?") 
      current_user.post(:status_message, :message => "xkcd \nhttp://xkcd.com/743/" )
      current_user.post(:status_message, :message => "I switched to Motoroi today, a Motorola Android-based phone, in Korea. Now, I am using Android phones in both the U.S. and Korea", :created_at => Time.now-930)
      current_user.post(:status_message, :message => "I had 5 hours to study for it :-( GREs on Thursday. Wunderbar.", :created_at => Time.now-43990)
      current_user.post(:status_message, :message => "Spotted in toy story 3: google maps, OSX, and windows XP. Two out of three isn't bad.", :created_at => Time.now-4390)
      current_user.post(:status_message,  :message => "Reddit\nhttp://reddit.com", :created_at => Time.now-54390)
      current_user.post(:status_message, :message => "Commercials for IE make me SO MAD and my friends just don't get why.", :created_at => Time.now-30900)
      current_user.post(:status_message, :message => "Zombo.com\nhttp://zombo.com", :created_at => Time.now-9090) 
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
        logger.info "Calling send_friend_request with #{rel_hash[:friend]} and #{current_user.groups.first}"
        current_user.send_friend_request_to(rel_hash[:friend], current_user.groups.first)
      end
    end
  end

  def zombiefriendaccept
    render :nothing => true
    Request.all.each{|r| 
      current_user.accept_and_respond(r.id, current_user.groups.first.id)
    }
  end

  def backer_info
    config = YAML.load_file(File.dirname(__FILE__) + '/../../config/deploy_config.yml') 
    config['servers']['backer']
  end

  def set_backer_number
    render :nothing => true
    seed_num_hash = {:seed_number => params[:number]}
    file = File.new(Rails.root.join('config','backer_number.yml'),'w')
    file.write(seed_num_hash.to_yaml)
    file.close
  end

  def set_profile_photo

    render :nothing => true
    album = Album.create(:person => current_user.person, :name => "Profile Photos")
    current_user.raw_visible_posts << album
    current_user.save
    
    backer_number = YAML.load_file(Rails.root.join('config','backer_number.yml'))[:seed_number].to_i
    username = backer_info[backer_number]['username'].gsub(/ /,'').downcase
    
      @fixture_name = File.dirname(__FILE__) + "/../../public/images/user/#{username}.jpg"
  
      photo = Photo.new(:person => current_user.person, :album => album)
      photo.image.store! File.open(@fixture_name)
      photo.save
      photo.reload
  
      current_user.raw_visible_posts << photo
      current_user.save
  
  
     current_user.update_profile(:image_url => photo.url(:thumb_medium))
     current_user.save
  end
  
  def log
    @log = `tail -n 200 log/development.log`
    
    render "shared/log"
  end
end
