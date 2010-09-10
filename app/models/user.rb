require 'lib/diaspora/user/friending.rb'
require 'lib/diaspora/user/querying.rb'
require 'lib/salmon/salmon'

class User
  include MongoMapper::Document
  include Diaspora::UserModules::Friending
  include Diaspora::UserModules::Querying
  include Encryptor::Private
  QUEUE = MessageHandler.new

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  key :username, :unique => true
         
  key :friend_ids,          Array
  key :pending_request_ids, Array
  key :visible_post_ids,    Array
  key :visible_person_ids,  Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends,           :in => :friend_ids,          :class_name => 'Person'
  many :visible_people,    :in => :visible_person_ids,  :class_name => 'Person' # One of these needs to go
  many :pending_requests,  :in => :pending_request_ids, :class_name => 'Request'
  many :raw_visible_posts, :in => :visible_post_ids,    :class_name => 'Post'

  many :groups, :class_name => 'Group'

  before_validation_on_create :setup_person
  before_validation :do_bad_things 
  
   def self.find_for_authentication(conditions={})
    if conditions[:username] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i # email regex
      conditions[:email] = conditions.delete(:username)
    end
    super
  end 

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

  def move_friend( opts = {})
    return true if opts[:to] == opts[:from]
    friend = Person.first(:_id => opts[:friend_id])
    if self.friend_ids.include?(friend.id)
      from_group = self.group_by_id(opts[:from]) 
      to_group = self.group_by_id(opts[:to])
      if from_group && to_group
        posts_to_move = from_group.posts.find_all_by_person_id(friend.id)
        to_group.people << friend
        to_group.posts << posts_to_move
        from_group.person_ids.delete(friend.id.to_id)
        posts_to_move.each{ |x| from_group.post_ids.delete(x.id)}
        from_group.save
        to_group.save
        return true
      end
    end
    false
  end

  ######## Posting ########
  def post(class_name, options = {})

    if class_name == :photo
      raise ArgumentError.new("No album_id given") unless options[:album_id]
      group_ids = groups_with_post( options[:album_id] )
      group_ids.map!{ |group| group.id }
    else
      group_ids = options.delete(:to)
    end

    group_ids = [group_ids] if group_ids.is_a? BSON::ObjectId
    raise ArgumentError.new("You must post to someone.") if group_ids.nil? || group_ids.empty?

    post = build_post(class_name, options)

    post.socket_to_uid(id, :group_ids => group_ids) if post.respond_to?(:socket_to_uid)
    push_to_groups(post, group_ids)

    post
  end

  def build_post( class_name, options = {})
    options[:person] = self.person
    model_class = class_name.to_s.camelize.constantize
    post = model_class.instantiate(options)
    post.save
    self.raw_visible_posts << post
    self.save
    post
  end

  def push_to_groups( post, group_ids )
    if group_ids == :all || group_ids == "all"
      groups = self.groups
    elsif group_ids.is_a?(Array) && group_ids.first.class == Group
      groups = group_ids
    else
      groups = self.groups.find_all_by_id( group_ids )
    end
    #send to the groups
    target_people = [] 

    groups.each{ |group|
      group.posts << post
      group.save
      target_people = target_people | group.people
    }
    push_to_people(post, target_people)
  end



  def push_to_people(post, people)
    people.each{|person|
      salmon(post, :to => person)
    }
  end

  def push_to_person( person, xml )
      Rails.logger.debug("Adding xml for #{self} to message queue to #{url}")
      QUEUE.add_post_request( person.receive_url, person.encrypt(xml) )
      QUEUE.process
      
  end

  def salmon( post, opts = {} )
    salmon = Salmon::SalmonSlap.create(self, post.to_diaspora_xml)
    push_to_person( opts[:to], salmon.to_xml)
    salmon
  end



  ######## Commenting  ########
  def comment(text, options = {})
    comment = build_comment(text, options)
    if comment
      dispatch_comment comment
      comment.socket_to_uid id
    end
    comment
  end
  
  def build_comment( text, options = {})
    raise "must comment on something!" unless options[:on]
    comment = Comment.new(:person_id => self.person.id, :text => text, :post => options[:on])
    comment.creator_signature = comment.sign_with_key(encryption_key)
    if comment.save
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
      push_to_people comment, people_in_groups(groups_with_post(comment.post.id))
    elsif owns? comment
      comment.save
      salmon comment, :to => comment.post.person 
    end
  end
  
  ######### Posts and Such ###############
  def retract( post )
    post.unsocket_from_uid(self.id) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    push_to_people retraction, people_in_groups(groups_with_post(post.id))
    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    params[:profile].delete(:image_url) if params[:profile][:image_url].empty?

    if self.person.update_attributes(params)
      push_to_groups profile, :all
      true
    else
      false
    end
  end

  ###### Receiving #######
  def receive_salmon ciphertext
    cleartext = decrypt( ciphertext)
    Rails.logger.info("Received a salmon: #{cleartext}")
    salmon = Salmon::SalmonSlap.parse cleartext
    if salmon.verified_for_key?(salmon.author.public_key)
      self.receive(salmon.data)
    end
  end

  def receive xml
    object = Diaspora::Parser.from_xml(xml)
    Rails.logger.debug("Receiving object for #{self.real_name}:\n#{object.inspect}")
    Rails.logger.debug("From: #{object.person.inspect}") if object.person

    if object.is_a? Retraction
      if object.type == 'Person'

        Rails.logger.info( "the person id is #{object.post_id} the friend found is #{visible_person_by_id(object.post_id).inspect}")
        unfriended_by visible_person_by_id(object.post_id)

      else
        object.perform self.id
        groups = self.groups_with_person(object.person)
        groups.each{ |group| group.post_ids.delete(object.post_id.to_id)
                             group.save
        }
      end
    elsif object.is_a? Request
      person = Diaspora::Parser.parse_or_find_person_from_xml( xml )
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
      object.person = Diaspora::Parser.parse_or_find_person_from_xml( xml ).save if object.person.nil?
      self.visible_people = self.visible_people | [object.person]
      self.save
      Rails.logger.debug("The person parsed from comment xml is #{object.person.inspect}") unless object.person.nil?
      object.person.save
    Rails.logger.debug("From: #{object.person.inspect}") if object.person
      raise "In receive for #{self.real_name}, signature was not valid on: #{object.inspect}" unless object.post.person == self.person || object.verify_post_creator_signature
      object.save
      unless owns?(object)
        dispatch_comment object
      end
      object.socket_to_uid(id)  if (object.respond_to?(:socket_to_uid) && !self.owns?(object))
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
  def self.instantiate!( opts = {} )
    opts[:person][:email] = opts[:email]
    opts[:person][:serialized_key] = generate_key
    User.create!( opts)
  end
	 	
  def terse_url
    terse = self.url.gsub(/(https?:|www\.)\/\//, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end

  def diaspora_handle
    "#{self.username}@#{self.terse_url}"
  end

  def do_bad_things
    self.password_confirmation = self.password
  end 

  def setup_person
    self.person.serialized_key ||= User.generate_key.export
    self.person.email ||= email
    self.person.save!
  end



  def as_json(opts={})
    {
      :user => {
        :posts            => self.raw_visible_posts.each{|post| post.as_json},
        :friends          => self.friends.each {|friend| friend.as_json},
        :groups           => self.groups.each  {|group|  group.as_json},
        :pending_requests => self.pending_requests.each{|request| request.as_json},
      }
    }
  end
    def self.generate_key
      OpenSSL::PKey::RSA::generate 4096
    end
end
