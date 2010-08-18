class User
  include MongoMapper::Document

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  key :friend_ids, Array
  key :pending_request_ids, Array
  key :visible_post_ids, Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends, :in => :friend_ids, :class_name => 'Person'
  many :pending_requests, :in => :pending_request_ids, :class_name => 'Request'
  many :raw_visible_posts, :in => :visible_post_ids, :class_name => 'Post'

  many :groups, :class_name => 'Group'

  before_validation_on_create :assign_key
  before_validation :do_bad_things
  
  ######## Making things work ########
  key :email, String
  ensure_index :email

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

  ######## Posting ########
  def post(class_name, options = {})
    options[:person] = self.person

    group_id = options[:group_id]
    options.delete(:group_id)

    model_class = class_name.to_s.camelize.constantize
    post = model_class.instantiate(options)
    post.creator_signature = post.sign_with_key(encryption_key)
    post.save
    post.notify_people

    post.socket_to_uid(id) if post.respond_to?(:socket_to_uid)

    self.raw_visible_posts << post
    self.save
    
    if group_id
      group = self.groups.find_by_id(group_id)
      group.posts << post
      group.save
    end

    post
  end
 
  def visible_posts( opts = {} )
    if opts[:by_members_of]
      group = self.groups.find_by_id( opts[:by_members_of].id )
      group.posts
    end
  end

  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    comment = Comment.new(:person_id => self.person.id, :text => text, :post => options[:on])
    comment.creator_signature = comment.sign_with_key(encryption_key)
    if comment.save
      dispatch_comment comment
      comment.socket_to_uid id
      comment
    else
      Rails.logger.warn "this failed to save: #{comment.inspect}"
      false
    end
  end
  
  def dispatch_comment( comment )
    if owns? comment.post
      comment.post_creator_signature = comment.sign_with_key(encryption_key)
      comment.save
      comment.push_downstream
    elsif owns? comment
      comment.save
      comment.push_upstream
    end
  end
  
  ######### Posts and Such ###############

  def retract( post )
    post.unsocket_from_uid(self.id) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    retraction.creator_signature = retraction.sign_with_key( encryption_key ) 
    retraction.notify_people
    retraction
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
    request = Request.find_by_id(friend_request_id)
    pending_requests.delete(request)
    
    activate_friend(request.person, group_by_id(group_id))

    request.reverse_for(self)
    request
  end
  
  def dispatch_friend_acceptance(request)
    request.push_to_url(request.callback_url)
    request.destroy unless request.callback_url.include? url
  end 
  
  def accept_and_respond(friend_request_id, group_id)
    dispatch_friend_acceptance(accept_friend_request(friend_request_id, group_id))
  end

  def ignore_friend_request(friend_request_id)
    request = Request.find_by_id(friend_request_id)
    person  = request.person

    person.user_refs -= 1

    self.pending_requests.delete(request)
    self.save

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
      self.pending_requests << friend_request
      self.save
      Rails.logger.info("#{self.real_name} has received a friend request")
      friend_request.save
    end
  end

  def unfriend(bad_friend)
    Rails.logger.info("#{self.real_name} is unfriending #{bad_friend.inspect}")
    retraction = Retraction.for(self)
    retraction.creator_signature = retraction.sign_with_key(encryption_key)
    retraction.push_to_url(bad_friend.receive_url) 
    remove_friend(bad_friend)
  end
  
  def remove_friend(bad_friend)
    raise "Friend not deleted" unless self.friend_ids.delete( bad_friend.id )
    groups.each{|g| g.person_ids.delete( bad_friend.id )}
    self.save

    self.raw_visible_posts.find_all_by_person_id( bad_friend.id ).each{|post|
      self.visible_post_ids.delete( post.id )
      post.user_refs -= 1
      (post.user_refs > 0 || post.person.owner.nil? == false) ?  post.save : post.destroy
    }
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
    raise "Signature was not valid on: #{object.inspect}" unless object.signature_valid?
    if object.is_a? Retraction
      if object.type == 'Person' && object.signature_valid?

        Rails.logger.info( "the person id is #{object.post_id} the friend found is #{visible_person_by_id(object.post_id).inspect}")
        unfriended_by visible_person_by_id(object.post_id)

      else
        object.perform self.id
        groups = self.groups_with_person(object.person)
        groups.each{ |group| group.post_ids.delete(ensure_bson(object.post_id))
                             group.save
        }
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

    elsif object.is_a?(Comment) 
      dispatch_comment object unless owns?(object)
    else
      Rails.logger.debug("Saving object: #{object}")
      object.user_refs += 1
      object.save
      
      self.raw_visible_posts << object
      self.save

      groups = self.groups_with_person(object.person)
      groups.each{ |group| 
        group.posts << object
        group.save
        object.socket_to_uid(id, :group_id => group.id) if (object.respond_to?(:socket_to_uid) && !self.owns?(object))
      }

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
  
  def visible_person_by_id( id )
    id = ensure_bson id
    return self.person if id == self.person.id
    friends.detect{|x| x.id == id }
  end

  def group_by_id( id )
    id = ensure_bson id
    groups.detect{|x| x.id == id }
  end

  def groups_with_person person
    id = ensure_bson person.id
    groups.select {|group| group.person_ids.include? id}
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
