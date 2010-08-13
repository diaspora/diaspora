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
  def send_friend_request_to(friend_url, group_id)
    unless self.friends.detect{ |x| x.receive_url == friend_url}
      request = Request.instantiate(:to => friend_url, :from => self.person, :into => group_id)
      if request.save
        self.pending_requests << request
        self.save

        group = self.groups.first(:id => group_id)

        group.requests << request
        group.save
        
        request.push_to_url friend_url
      end
      request
    end
  end 

  def accept_friend_request(friend_request_id, group_id)
    request = Request.where(:id => friend_request_id).first
    n = pending_requests.delete(request)
    
    friends << request.person
    save

    group = self.groups.first(:id => group_id)
    group.people << request.person
    group.save

    request.reverse self

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
    if request_from_me?(friend_request)
      activate_friend(friend_request.person, friend_request.group_id)

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

  def send_request(rel_hash, group)
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend], group)
    else
      raise "you can't do anything to that url"
    end
  end
  
  def activate_friend(person, group)
    group.people << person
    friends << person
    group.save
  end

  def request_from_me?(request)
    pending_requests.detect{|req| (req.callback_url == person.receive_url) && (req.destination_url == person.receive_url)}
  end

  ###### Receiving #######
  def receive xml
    object = Diaspora::Parser.from_xml(xml)
    Rails.logger.debug("Receiving object:\n#{object.inspect}")

    if object.is_a? Retraction
      object.perform self.id 
    elsif object.is_a? Request
      person = Diaspora::Parser.get_or_create_person_object_from_xml( xml )
      person.serialized_key ||= object.exported_key
      object.person = person
      object.person.save
      object.save
      receive_friend_request(object)
    elsif object.is_a? Profile
      person = Diaspora::Parser.owner_id_from_xml xml
      person.profile = object
      person.save  
    elsif object.verify_creator_signature == true 
      Rails.logger.debug("Saving object with success: #{object.save}")
      object.socket_to_uid( id) if object.respond_to? :socket_to_uid
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
