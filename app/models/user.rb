class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  
  before_validation_on_create :assign_key
  validates_presence_of :profile
  
  before_validation :do_bad_things
 
  
  ######## Posting ########

  def post(class_name, options = {})
    options[:person] = self
    model_class = class_name.to_s.camelize.constantize
    post = model_class.instantiate(options)
  end

  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    c = Comment.new(:person_id => self.id, :text => text, :post => options[:on])
    if c.save
      if mine?(c.post)
        c.push_to(c.post.people_with_permissions)  # should return plucky query
      else
        c.push_to([c.post.person])
      end
      true
    end
    false
  end
  
  ##profile
  def update_profile(params)
    if self.update_attributes(params)
      puts self.profile.class
      self.profile.notify_people!
      true
    else
      false
    end
  end

  ######### Friend Requesting
  def send_friend_request_to(friend_url)
    unless Person.where(:url => friend_url).first
      p = Request.instantiate(:to => friend_url, :from => self)
      if p.save
        p.push_to_url friend_url
      end
      p
    end
  end 

  def accept_friend_request(friend_request_id)
    request = Request.where(:id => friend_request_id).first
    request.activate_friend
    request.person = self
    request.exported_key = self.export_key
    request.destination_url = request.callback_url
    request.push_to_url(request.callback_url)
    request.destroy
  end

  def ignore_friend_request(friend_request_id)
    request = Request.first(:id => friend_request_id)
    person = request.person
    person.destroy unless person.active
    request.destroy
  end

  def receive_friend_request(friend_request)
    Rails.logger.info("receiving friend request #{friend_request.to_json}")
    if Request.where(:callback_url => friend_request.callback_url).first
      friend_request.activate_friend
      friend_request.destroy
    else
      friend_request.person.save
      friend_request.save
    end
  end

  def unfriend(friend_id)
    bad_friend  = Person.first(:id => friend_id, :active => true)
    if bad_friend 
       Retraction.for(self).push_to_url(bad_friend.url) 
       bad_friend.destroy
    end
  end

  def send_request(rel_hash)
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend])
    else
      raise "you can't do anything to that url"
    end
  end

  
  ###Helpers############
  def mine?(post)
    self == post.person
  end

  def terse_url
    terse= self.url.gsub(/https?:\/\//, '')
    terse.gsub!(/www\./, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end
 
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  def self.owner
    User.first
  end
  
  protected
  
  def assign_key
    generate_key
  end

  def generate_key
    puts "Generating key"
    
    self.rsa_key = OpenSSL::PKey::RSA::generate 1024 
    
  end

end
