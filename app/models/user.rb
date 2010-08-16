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

        group = self.group_by_id(group_id)

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
    
    activate_friend(request.person, group_by_id(group_id))

    request.reverse self
    request
  end
  
  def dispatch_friend_acceptance(request)
    request.push_to_url(request.callback_url)
    request.destroy unless request.callback_url.include? user.url
  end 
  
  def accept_and_respond(friend_request_id, group_id)
    dispatch_friend_acceptance(accept_friend_request(friend_request_id, group_id))
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
    Rails.logger.info("receiving friend request #{friend_request.to_json}")
    if request_from_me?(friend_request)
      group = self.group_by_id(friend_request.group_id)
      activate_friend(friend_request.person, group)

      Rails.logger.info("#{self.real_name}'s friend request has been accepted")
      friend_request.destroy
    else
      friend_request.person.user_refs += 1
      friend_request.person.save
      pending_requests << friend_request
      save
      Rails.logger.info("#{self.real_name} has received a friend request")
      friend_request.save
    end
  end

  def unfriend(bad_friend)
    Rails.logger.info("#{self.real_name} is unfriending #{bad_friend.inspect}")
    Retraction.for(self).push_to_url(bad_friend.receive_url) 
    remove_friend(bad_friend)
  end
  
  def remove_friend(bad_friend)
    raise "Friend not deleted" unless self.friend_ids.delete( bad_friend.id )
    groups.each{|g| g.person_ids.delete( bad_friend.id )}
    self.save
    bad_friend.user_refs -= 1
    (bad_friend.user_refs > 0 || bad_friend.owner.nil? == false) ?  bad_friend.save : bad_friend.destroy
  end

  def unfriended_by(bad_friend)
    Rails.logger.info("#{self.real_name} is being unfriended by #{bad_friend.inspect}")
    remove_friend bad_friend
  end

  def send_request(rel_hash, group)
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend], group)
    else
      raise "you can't do anything to that url"
    end
  end
  
  def activate_friend(person, group)
    person.user_refs += 1
    group.people << person
    friends << person
    person.save
    group.save
    save
  end

  def request_from_me?(request)
    pending_requests.detect{|req| (req.callback_url == person.receive_url) && (req.destination_url == person.receive_url)}
  end

  ###### Receiving #######
  def receive xml
    object = Diaspora::Parser.from_xml(xml)
    Rails.logger.debug("Receiving object:\n#{object.inspect}")

    if object.is_a? Retraction
      if object.type == 'Person' && object.signature_valid?

        Rails.logger.info( "the person id is #{object.post_id} the friend found is #{friend_by_id(object.post_id).inspect}")
        unfriended_by friend_by_id(object.post_id)

      else
        object.perform self.id
      end
    elsif object.is_a? Request
      person = Diaspora::Parser.get_or_create_person_object_from_xml( xml )
      person.serialized_key ||= object.exported_key
      object.person = person
      object.person.save
      old_request =  Request.first(:id => object.id)
      object.group_id = old_request.group_id if old_request
      object.save
      receive_friend_request(object)
    elsif object.is_a? Profile
      person = Diaspora::Parser.owner_id_from_xml xml
      person.profile = object
      person.save  
    elsif object.verify_creator_signature == true 
      Rails.logger.debug("Saving object: #{object}")
      object.save
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
  
  def friend_by_id( id )
    friends.detect{|x| x.id == ensure_bson( id ) }
  end

  def group_by_id( id )
    groups.detect{|x| x.id == ensure_bson( id ) }
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

  def ensure_bson id 
    id.class == String ? BSON::ObjectID(id) : id 
  end
end
