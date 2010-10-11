#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/diaspora/user/friending')
require File.join(Rails.root, 'lib/diaspora/user/querying')
require File.join(Rails.root, 'lib/diaspora/user/receiving')
require File.join(Rails.root, 'lib/salmon/salmon')

class User
  include MongoMapper::Document
  plugin MongoMapper::Devise
  include Diaspora::UserModules::Friending
  include Diaspora::UserModules::Querying
  include Diaspora::UserModules::Receiving
  include Encryptor::Private
  QUEUE = MessageHandler.new

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  key :username, :unique => true
  key :serialized_private_key, String

  key :friend_ids,          Array
  key :pending_request_ids, Array
  key :visible_post_ids,    Array
  key :visible_person_ids,  Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends,           :in => :friend_ids,          :class_name => 'Person'
  many :visible_people,    :in => :visible_person_ids,  :class_name => 'Person' # One of these needs to go
  many :pending_requests,  :in => :pending_request_ids, :class_name => 'Request'
  many :raw_visible_posts, :in => :visible_post_ids,    :class_name => 'Post'

  many :aspects, :class_name => 'Aspect'

  after_create :seed_aspects

  before_validation :downcase_username, :on => :create

  before_destroy :unfriend_everyone, :remove_person

   def self.find_for_authentication(conditions={})
    if conditions[:username] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i # email regex
      conditions[:email] = conditions.delete(:username)
    else
      conditions[:username].downcase!
    end
    super
  end

  ######## Making things work ########
  key :email, String

  def method_missing(method, *args)
    self.person.send(method, *args)
  end

  def real_name
    "#{person.profile.first_name.to_s} #{person.profile.last_name.to_s}"
  end

  ######### Aspects ######################
  def aspect( opts = {} )
    opts[:user] = self
    Aspect.create(opts)
  end

  def drop_aspect( aspect )
    if aspect.people.size == 0
      aspect.destroy
    else
      raise "Aspect not empty"
    end
  end

  def move_friend( opts = {})
    return true if opts[:to] == opts[:from]
    friend = Person.first(:_id => opts[:friend_id])
    if self.friend_ids.include?(friend.id)
      from_aspect = self.aspect_by_id(opts[:from])
      to_aspect = self.aspect_by_id(opts[:to])
      if from_aspect && to_aspect
        posts_to_move = from_aspect.posts.find_all_by_person_id(friend.id)
        to_aspect.people << friend
        to_aspect.posts << posts_to_move
        from_aspect.person_ids.delete(friend.id.to_id)
        posts_to_move.each{ |x| from_aspect.post_ids.delete(x.id)}
        from_aspect.save
        to_aspect.save
        return true
      end
    end
    false
  end

  ######## Posting ########
  def post(class_name, options = {})
    if class_name == :photo
      raise ArgumentError.new("No album_id given") unless options[:album_id]
      aspect_ids = aspects_with_post( options[:album_id] )
      aspect_ids.map!{ |aspect| aspect.id }
    else
      aspect_ids = options.delete(:to)
    end

    aspect_ids = validate_aspect_permissions(aspect_ids)

    intitial_post(class_name, aspect_ids, options)
  end

  def intitial_post(class_name, aspect_ids, options = {})
    post = build_post(class_name, options)
    post.socket_to_uid(id, :aspect_ids => aspect_ids) if post.respond_to?(:socket_to_uid)
    push_to_aspects(post, aspect_ids)
    post
  end

  def update_post( post, post_hash = {} )
    if self.owns? post
      post.update_attributes(post_hash)
    end
  end

  def validate_aspect_permissions(aspect_ids)
    if aspect_ids == "all"
      return aspect_ids
    end

    aspect_ids = [aspect_ids.to_s] unless aspect_ids.is_a? Array

    if aspect_ids.nil? || aspect_ids.empty?
      raise ArgumentError.new("You must post to someone.")
    end

    aspect_ids.each do |aspect_id|
      unless self.aspects.find(aspect_id)
        raise ArgumentError.new("Cannot post to an aspect you do not own.")
      end
    end

    aspect_ids
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

  def push_to_aspects( post, aspect_ids )
    if aspect_ids == :all || aspect_ids == "all"
      aspects = self.aspects
    elsif aspect_ids.is_a?(Array) && aspect_ids.first.class == Aspect
      aspects = aspect_ids
    else
      aspects = self.aspects.find_all_by_id( aspect_ids )
    end
    #send to the aspects
    target_people = []

    aspects.each{ |aspect|
      aspect.posts << post
      aspect.save
      target_people = target_people | aspect.people
    }

    push_to_hub(post) if post.respond_to?(:public) && post.public

    push_to_people(post, target_people)
  end

  def push_to_people(post, people)
    salmon = salmon(post)
    people.each{|person|
      xml = salmon.xml_for person
      push_to_person( person, xml)
    }
  end

  def push_to_person( person, xml )
    Rails.logger.debug("#{self.real_name} is adding xml to message queue to #{person.receive_url}")
    QUEUE.add_post_request( person.receive_url, xml )
    QUEUE.process
  end

  def push_to_hub(post)
    Rails.logger.debug("Pushing update to pubsub server #{APP_CONFIG[:pubsub_server]} with url #{self.public_url}")
    QUEUE.add_hub_notification(APP_CONFIG[:pubsub_server], self.public_url)
  end

  def salmon( post )
    created_salmon = Salmon::SalmonSlap.create(self, post.to_diaspora_xml)
    created_salmon
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
      push_to_people comment, people_in_aspects(aspects_with_post(comment.post.id))
    elsif owns? comment
      comment.save
      push_to_people comment, [comment.post.person]
    end
  end

  ######### Posts and Such ###############
  def retract( post )
    aspect_ids = aspects_with_post( post.id )
    aspect_ids.map!{|aspect| aspect.id.to_s}

    post.unsocket_from_uid(self.id, :aspect_ids => aspect_ids) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    push_to_people retraction, people_in_aspects(aspects_with_post(post.id))
    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    if self.person.update_attributes(params)
      push_to_aspects profile, :all
      true
    else
      false
    end
  end

  ###Helpers############
  def self.instantiate!( opts = {} )
    opts[:person][:diaspora_handle] = "#{opts[:username]}@#{APP_CONFIG[:terse_pod_url]}"
    opts[:person][:url] = APP_CONFIG[:pod_url]

    opts[:serialized_private_key] = generate_key
    opts[:person][:serialized_public_key] = opts[:serialized_private_key].public_key
    User.create(opts)
  end

  def seed_aspects
    aspect(:name => "Family")
    aspect(:name => "Work")
  end

  def diaspora_handle
    "#{self.username}@#{APP_CONFIG[:terse_pod_url]}"
  end

  def downcase_username
    username.downcase! if username
  end

  def as_json(opts={})
    {
      :user => {
        :posts            => self.raw_visible_posts.each{|post| post.as_json},
        :friends          => self.friends.each {|friend| friend.as_json},
        :aspects           => self.aspects.each  {|aspect|  aspect.as_json},
        :pending_requests => self.pending_requests.each{|request| request.as_json},
      }
    }
  end


  def self.generate_key
    OpenSSL::PKey::RSA::generate 4096
  end

  def encryption_key
    OpenSSL::PKey::RSA.new( serialized_private_key )
  end
  
  protected

  def remove_person
    self.person.destroy
  end

  def unfriend_everyone
    friends.each{ |friend|
      if friend.owner?
        friend.owner.unfriended_by (self.person )
      else 
        self.unfriend( friend )
      end
    }
  end
end
