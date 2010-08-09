class User
  include MongoMapper::Document

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  key :friend_ids, Array
  key :pending_friend_ids, Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends, :in => :friend_ids, :class_name => 'Person'
  many :pending_friends, :in => :pending_friend_ids, :class_name => 'Person'

  before_validation_on_create :assign_key
  before_validation :do_bad_things
  
  ######## Posting ########
  key :email, String

  def method_missing(method, *args)
    self.person.send(method, *args)
  end


  def real_name
    "#{person.profile.first_name.to_s} #{person.profile.last_name.to_s}"
  end
  


  ######### Friend Requesting
  def send_friend_request_to(friend_url)
    unless Person.where(:url => friend_url).first
      p = Request.instantiate(:to => friend_url, :from => self.person)
      if p.save
        p.push_to_url friend_url
      end
      p 
    end
  end 

  def accept_friend_request(friend_request_id)
    request = Request.where(:id => friend_request_id).first
    pending_friends.delete(request.person)
    friends << request.person

    request.person = self
    request.exported_key = self.export_key
    request.destination_url = request.callback_url
    request.push_to_url(request.callback_url)
    request.destroy
  end

  def ignore_friend_request(friend_request_id)
    request = Request.first(:id => friend_request_id)
    person = request.person
    pending_friends.delete(request.person)
    person.destroy unless person.user_refs > 0
    request.destroy
  end

  def receive_friend_request(friend_request)
    Rails.logger.info("receiving friend request #{friend_request.to_json}")
    
    friend_request.person.serialized_key = friend_request.exported_key
    if Request.where(:callback_url => friend_request.callback_url).first
      friend_request.activate_friend
      Rails.logger.info("#{self.real_name}'s friend request has been accepted")
      friend_request.destroy
    else
      friend_request.person.save
      pending_friends << friend_request.person
      save
      Rails.logger.info("#{self.real_name} has received a friend request")
      friend_request.save
    end
  end

  def unfriend(friend_id)
    bad_friend = Person.first(:_id => friend_id)

    self.friend_ids.delete( friend_id )
    self.save

    if bad_friend 
      Retraction.for(self).push_to_url(bad_friend.url) 
      bad_friend.update_attributes(:user_refs => bad_friend.user_refs - 1)
      bad_friend.destroy if bad_friend.user_refs == 0
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
    self.person.serialized_key ||= generate_key.export
  end

  def generate_key
    OpenSSL::PKey::RSA::generate 1024 
  end

end
