#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Reshare < Post

  belongs_to :root, :class_name => 'Post', :foreign_key => :root_guid, :primary_key => :guid
  validate :root_must_be_public
  attr_accessible :root_guid, :public
  validates_presence_of :root, :on => :create
  validates_uniqueness_of :root_guid, :scope => :author_id
  delegate :author, to: :root, prefix: true

  xml_attr :root_diaspora_id
  xml_attr :root_guid

  before_validation do
    self.public = true
  end

  after_create do
    self.root.update_reshares_counter
  end

  after_destroy do
    self.root.update_reshares_counter if self.root.present?
  end

  def root_diaspora_id
    self.root.author.diaspora_handle
  end

  def o_embed_cache
    self.root ? root.o_embed_cache : super
  end

  def raw_message
    self.root ? root.raw_message : super
  end

  def mentioned_people
    self.root ? root.mentioned_people : super
  end

  def photos
    self.root ? root.photos : []
  end

  def frame_name
    self.root ? root.frame_name : nil
  end

  def receive(recipient, sender)
    local_reshare = Reshare.where(:guid => self.guid).first
    if local_reshare && local_reshare.root.author_id == recipient.person.id
      return unless recipient.has_contact_for?(sender)
    end
    super(recipient, sender)
  end

  def comment_email_subject
    I18n.t('reshares.comment_email_subject', :resharer => author.name, :author => root.author_name)
  end

  def notification_type(user, person)
    Notifications::Reshared if root.author == user.person
  end

  def nsfw
    root.try(:nsfw)
  end

  def absolute_root
    current = self
    while( current.is_a?(Reshare) )
      current = current.root
    end

    current
  end

  private

  def after_parse
    root_author = Webfinger.new(@root_diaspora_id).fetch
    root_author.save! unless root_author.persisted?

    return if Post.exists?(:guid => self.root_guid)

    fetched_post = self.class.fetch_post(root_author, self.root_guid)

    if fetched_post
      #Why are we checking for this?
      if root_author.diaspora_handle != fetched_post.diaspora_handle
        raise "Diaspora ID (#{fetched_post.diaspora_handle}) in the root does not match the Diaspora ID (#{root_author.diaspora_handle}) specified in the reshare!"
      end

      fetched_post.save!
    end
  end

  # Fetch a remote public post, used for receiving reshares of unknown posts
  # @param [Person] author the remote post's author
  # @param [String] guid the remote post's guid
  # @return [Post] an unsaved remote post or false if the post was not found
  def self.fetch_post author, guid
    url = author.url + "/p/#{guid}.xml"
    response = Faraday.get(url)
    return false if response.status == 404 # Old pod, friendika
    raise "Failed to get #{url}" unless response.success? # Other error, N/A for example
    Diaspora::Parser.from_xml(response.body)
  end

  def root_must_be_public
    if self.root && !self.root.public
      errors[:base] << "Only posts which are public may be reshared."
      return false
    end
  end
end
