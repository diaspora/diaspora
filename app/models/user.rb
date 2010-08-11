class User
  include MongoMapper::Document

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  key :friend_ids, Array
  key :pending_request_ids, Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends, :in => :friend_ids, :class_name => 'Person'
  many :pending_requests, :in => :pending_request_ids, :class_name => 'Request'

  many :groups, :class_name => 'Group'

  before_validation_on_create :assign_key
  before_validation :do_bad_things
  
  ######## Making things work ########

  key :email, String

  def method_missing(method, *args)
    self.person.send(method, *args)
  end


  def real_name
    "#{person.profile.first_name.to_s} #{person.profile.last_name.to_s}"
  end
  
  ######### Groups ######################

  def group( opts = {} )
    opts[:user] = self
    Group.create(opts)
  end

  ######### Friend Requesting ###########
  def send_friend_request_to(friend_url)

    unless self.friends.detect{ |x| x.receive_url == friend_url}
      p = Request.instantiate(:to => friend_url, :from => self.person)
      if p.save
        self.pending_requests << p
        self.save
        p.push_to_url friend_url
      end
      p 
    end
  end 

  def accept_friend_request(friend_request_id)
    request = Request.where(:id => friend_request_id).first
    n = pending_requests.delete(request)
    
    friends << request.person
    save

    request.person = self.person
    request.exported_key = self.export_key
    request.destination_url = request.callback_url
    request.push_to_url(request.callback_url)
    request.destroy
  end

  def ignore_friend_request(friend_request_id)
    request = Request.first(:id => friend_request_id)
    person = request.person
    person.user_refs -= 1
    pending_requests.delete(request)
    save
    (person.user_refs > 0 || person.owner.nil? == false) ?  person.save : person.destroy
    request.destroy
  end

  def receive_friend_request(friend_request)
    Rails.logger.debug("receiving friend request #{friend_request.to_json}")
    if pending_requests.detect{|req| (req.callback_url == person.receive_url) && (req.destination_url == person.receive_url)}
      activate_friend friend_request.person
      Rails.logger.debug("#{self.real_name}'s friend request has been accepted")
      friend_request.destroy
    else

      friend_request.person.user_refs += 1
      friend_request.person.save
      pending_requests << friend_request
      save
      Rails.logger.debug("#{self.real_name} has received a friend request")
      friend_request.save
    end
  end

  def unfriend(friend_id)
    bad_friend = Person.first(:_id => friend_id)

    self.friend_ids.delete( friend_id )
    self.save

    if bad_friend 
      Retraction.for(self).push_to_url(bad_friend.receive_url) 
      bad_friend.update_attributes(:user_refs => bad_friend.user_refs - 1)
      (bad_friend.user_refs > 0 || bad_friend.owner.nil? == false) ?  bad_friend.save : bad_friend.destroy
    end
  end

  def send_request(rel_hash)
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend])
    else
      raise "you can't do anything to that url"
    end
  end
  
  def activate_friend(person)
    friends << person
    save
  end

  ###### Receiving #######
  def receive xml
    object = Diaspora::Parser.parse_from_xml(xml)
    Rails.logger.debug("Receiving object:\n#{object.inspect}")

    if object.is_a? Retraction
      Rails.logger.debug "Got a retraction for #{object.post_id}"
      object.perform
      
    elsif object.is_a? Request
      receive_friend_request(object)

    elsif object.is_a? Profile
      object.save

    elsif object.respond_to?(:person) && !(object.person.nil?) && !(object.person.is_a? User) 
      Rails.logger.debug("Saving object with success: #{object.save}")
    end
  end

  ###Helpers############
  def self.instantiate( opts = {} )
    opts[:person][:email] = opts[:email]
    opts[:person][:serialized_key] = generate_key
    User.create( opts)
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
    self.person.serialized_key ||= generate_key.export
  end

  def generate_key
    OpenSSL::PKey::RSA::generate 1024 
  end

  def self.generate_key
    OpenSSL::PKey::RSA::generate 1024 
  end

end
