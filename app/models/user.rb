#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/diaspora/user')
require File.join(Rails.root, 'lib/salmon/salmon')

class User
  include MongoMapper::Document
  include Diaspora::UserModules
  include Encryptor::Private

  plugin MongoMapper::Devise

  QUEUE = MessageHandler.new

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  key :username
  key :serialized_private_key, String
  key :invites, Integer, :default => 5
  key :invitation_token, String
  key :invitation_sent_at, DateTime
  key :pending_request_ids, Array, :typecast => 'ObjectId'
  key :visible_post_ids, Array, :typecast => 'ObjectId'
  key :visible_person_ids, Array, :typecast => 'ObjectId'

  key :getting_started, Boolean, :default => true

  key :language, String

  before_validation :strip_and_downcase_username, :on => :create
  before_validation :set_current_language, :on => :create

  validates_presence_of :username
  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of :username, :with => /\A[A-Za-z0-9_.]+\z/
  validates_length_of :username, :maximum => 32
  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGE_CODES

  validates_presence_of :person, :unless => proc {|user| user.invitation_token.present?}
  validates_associated :person

  one :person, :class => Person, :foreign_key => :owner_id

  many :invitations_from_me, :class => Invitation, :foreign_key => :from_id
  many :invitations_to_me, :class => Invitation, :foreign_key => :to_id
  many :contacts, :class => Contact, :foreign_key => :user_id
  many :visible_people, :in => :visible_person_ids, :class => Person # One of these needs to go
  many :pending_requests, :in => :pending_request_ids, :class => Request
  many :raw_visible_posts, :in => :visible_post_ids, :class => Post
  many :aspects, :class => Aspect, :dependent => :destroy

  many :services, :class => Service

  #after_create :seed_aspects

  before_destroy :disconnect_everyone, :remove_person
  before_save do
    person.save if person
  end

  attr_accessible :getting_started, :password, :password_confirmation, :language,

  def strip_and_downcase_username
    if username.present?
      username.strip!
      username.downcase!
    end
  end

  def set_current_language
    self.language = I18n.locale.to_s if self.language.blank?
  end

  def self.find_for_authentication(conditions={})
    if conditions[:username] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i # email regex
      conditions[:email] = conditions.delete(:username)
    end
    super
  end

  def has_incoming_request_from(person)
    self.pending_requests.select do |req|
      req.to_id == self.person.id
    end.any? { |req| req.from_id == person.id }
  end

  ######## Making things work ########
  key :email, String

  def method_missing(method, *args)
    self.person.send(method, *args) if self.person
  end

  ######### Aspects ######################
  def drop_aspect(aspect)
    if aspect.contacts.count == 0
      aspect.destroy
    else
      raise "Aspect not empty"
    end
  end

  def move_contact(opts = {})
    if opts[:to] == opts[:from]
      true
    elsif opts[:person_id] && opts[:to] && opts[:from]
      from_aspect = self.aspects.find_by_id(opts[:from])

      if add_person_to_aspect(opts[:person_id], opts[:to])
        delete_person_from_aspect(opts[:person_id], opts[:from])
      end
    end
  end

  def add_person_to_aspect(person_id, aspect_id)
    contact = contact_for(Person.find(person_id))
    raise "Can not add person to an aspect you do not own" unless aspect = self.aspects.find_by_id(aspect_id)
    raise "Can not add person you are not connected to" unless contact
    raise 'Can not add person who is already in the aspect' if aspect.contacts.include?(contact)
    contact.aspects << aspect
    contact.save!
    aspect.save!
  end

  def delete_person_from_aspect(person_id, aspect_id, opts = {})
    aspect = Aspect.find(aspect_id)
    raise "Can not delete a person from an aspect you do not own" unless aspect.user == self
    contact = contact_for Person.find(person_id)

    if opts[:force] || contact.aspect_ids.count > 1
      contact.aspect_ids.delete aspect.id
      contact.save!
      aspect.save!
    else
      raise "Can not delete a person from last aspect"
    end
  end

  ######## Posting ########
  def post(class_name, opts = {})
    post = build_post(class_name, opts)

    if post.save
      raise 'MongoMapper failed to catch a failed save' unless post.id
      dispatch_post(post, :to => opts[:to])
    end
    post
  end

  def build_post(class_name, opts = {})
    opts[:person] = self.person
    opts[:diaspora_handle] = self.person.diaspora_handle

    model_class = class_name.to_s.camelize.constantize
    model_class.instantiate(opts)
  end

  def dispatch_post(post, opts = {})
    aspect_ids = opts.delete(:to)

    aspect_ids = validate_aspect_permissions(aspect_ids)
    self.raw_visible_posts << post
    self.save
    Rails.logger.info("Pushing: #{post.inspect} out to aspects")
    push_to_aspects(post, aspect_ids)
    post.socket_to_uid(id, :aspect_ids => aspect_ids) if post.respond_to?(:socket_to_uid) && !post.pending
    if post.public
      self.services.each do |service|
        self.send("post_to_#{service.provider}".to_sym, service, post.message)
      end
    end
  end

  def post_to_facebook(service, message)
    Rails.logger.info("Sending a message: #{message} to Facebook")
    EventMachine::HttpRequest.new("https://graph.facebook.com/me/feed?message=#{message}&access_token=#{service.access_token}").post
  end

  def post_to_twitter(service, message)
    oauth = Twitter::OAuth.new(SERVICES['twitter']['consumer_token'], SERVICES['twitter']['consumer_secret'])
    oauth.authorize_from_access(service.access_token, service.access_secret)
    client = Twitter::Base.new(oauth)
    client.update(message)
  end

  def update_post(post, post_hash = {})
    if self.owns? post
      post.update_attributes(post_hash)
      aspects = aspects_with_post(post.id)
      self.push_to_aspects(post, aspects)
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

  def push_to_aspects(post, aspect_ids)
    if aspect_ids == :all || aspect_ids == "all"
      aspects = self.aspects
    elsif aspect_ids.is_a?(Array) && aspect_ids.first.class == Aspect
      aspects = aspect_ids
    else
      aspects = self.aspects.find_all_by_id(aspect_ids)
    end
    #send to the aspects
    target_contacts = []

    aspects.each { |aspect|
      aspect.posts << post
      aspect.save
      target_contacts = target_contacts | aspect.contacts
    }

    push_to_hub(post) if post.respond_to?(:public) && post.public

    push_to_people(post, self.person_objects(target_contacts))
  end

  def push_to_people(post, people)
    salmon = salmon(post)
    people.each do |person|
      push_to_person(salmon, post, person)
    end
  end

  def push_to_person(salmon, post, person)
    person.reload # Sadly, we need this for Ruby 1.9.
    # person.owner will always return a ProxyObject.
    # calling nil? performs a necessary evaluation.
    unless person.owner.nil?
      Rails.logger.info("event=push_to_person route=local sender=#{self.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{post.class}")
      person.owner.receive(post.to_diaspora_xml, self.person)
    else
      xml = salmon.xml_for person
      Rails.logger.info("event=push_to_person route=remote sender=#{self.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{post.class}")
      QUEUE.add_post_request(person.receive_url, xml)
      QUEUE.process
    end
  end

  def push_to_hub(post)
    Rails.logger.debug("event=push_to_hub target=#{APP_CONFIG[:pubsub_server]} sender_url=#{self.public_url}")
    QUEUE.add_hub_notification(APP_CONFIG[:pubsub_server], self.public_url)
  end

  def salmon(post)
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

  def build_comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    comment = Comment.new(:person_id => self.person.id, :diaspora_handle => self.person.diaspora_handle, :text => text, :post => options[:on])
    comment.creator_signature = comment.sign_with_key(encryption_key)
    if comment.save
      comment
    else
      Rails.logger.warn "event=build_comment status=save_failure user=#{self.diaspora_handle} comment=#{comment.inspect}"
      false
    end
  end

  def dispatch_comment(comment)
    if owns? comment.post
      Rails.logger.info "event=dispatch_comment direction=downstream user=#{self.diaspora_handle} comment=#{comment.inspect}"
      comment.post_creator_signature = comment.sign_with_key(encryption_key)
      comment.save
      aspects = aspects_with_post(comment.post_id)
      push_to_people(comment, people_in_aspects(aspects))
    elsif owns? comment
      Rails.logger.info "event=dispatch_comment direction=upstream user=#{self.diaspora_handle} comment=#{comment.inspect}"
      comment.save
      push_to_people comment, [comment.post.person]
    end
  end

  ######### Posts and Such ###############
  def retract(post)
    aspect_ids = aspects_with_post(post.id)
    aspect_ids.map! { |aspect| aspect.id.to_s }

    post.unsocket_from_uid(self.id, :aspect_ids => aspect_ids) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    push_to_people retraction, people_in_aspects(aspects_with_post(post.id))
    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    if self.person.profile.update_attributes(params)
      push_to_aspects profile, :all
      true
    else
      false
    end
  end

  ###Invitations############
  def invite_user(opts = {})
    aspect_id = opts.delete(:aspect_id)
    if aspect_id == nil
      raise "Must invite into aspect"
    end
    aspect_object = self.aspects.find_by_id(aspect_id)
    if !(aspect_object)
      raise "Must invite to your aspect"
    else
      Invitation.invite(:email => opts[:email],
                        :from => self,
                        :into => aspect_object,
                        :message => opts[:invite_message])

    end
  end

  def accept_invitation!(opts = {})
    if self.invited?
      log_string = "event=invitation_accepted username=#{opts[:username]} "
      log_string << "inviter=#{invitations_to_me.first.from.diaspora_handle}" if invitations_to_me.first
      Rails.logger.info log_string
      self.setup(opts)

      self.invitation_token = nil
      self.password              = opts[:password]
      self.password_confirmation = opts[:password_confirmation]
      self.person.save!
      self.save!
      invitations_to_me.each{|invitation| invitation.to_request!}

      self.reload # Because to_request adds a request and saves elsewhere
      self
    end
  end

  ###Helpers############
  def self.build(opts = {})
    u = User.new(opts)
    u.email = opts[:email]
    u.setup(opts)
    u
  end

  def setup(opts)
    self.username = opts[:username]
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0

    opts[:person] ||= {}
    opts[:person][:profile] ||= Profile.new

    self.person = Person.new(opts[:person])
    self.person.diaspora_handle = "#{opts[:username]}@#{APP_CONFIG[:terse_pod_url]}"
    self.person.url = APP_CONFIG[:pod_url]
    new_key = User.generate_key
    self.serialized_private_key = new_key
    self.person.serialized_public_key = new_key.public_key

    self
  end


  def seed_aspects
    self.aspects.create(:name => I18n.t('aspects.seed.family'))
    self.aspects.create(:name => I18n.t('aspects.seed.work'))
  end

  def as_json(opts={})
    {
      :user => {
        :posts            => self.raw_visible_posts.each { |post| post.as_json },
        :contacts         => self.contacts.each { |contact| contact.as_json },
        :aspects          => self.aspects.each { |aspect| aspect.as_json },
        :pending_requests => self.pending_requests.each { |request| request.as_json },
      }
    }
  end


  def self.generate_key
    key_size = (Rails.env == 'test' ? 512 : 4096)
    OpenSSL::PKey::RSA::generate key_size
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(serialized_private_key)
  end

  protected

  def remove_person
    self.person.destroy
  end

  def disconnect_everyone
    contacts.each { |contact|
      if contact.person.owner?
        contact.person.owner.disconnected_by self.person
      else
        self.disconnect contact
      end
    }
  end
end
