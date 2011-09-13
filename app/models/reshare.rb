class Reshare < Post

  belongs_to :root, :class_name => 'Post', :foreign_key => :root_guid, :primary_key => :guid
  validate :root_must_be_public
  attr_accessible :root_guid, :public
  validates_presence_of :root, :on => :create
  validates_uniqueness_of :root_guid, :scope => :author_id

  xml_attr :root_diaspora_id
  xml_attr :root_guid

  before_validation do
    self.public = true
  end

  def root_diaspora_id
    self.root.author.diaspora_handle
  end

  def receive(recipient, sender)
    local_reshare = Reshare.where(:guid => self.guid).first
    if local_reshare && local_reshare.root.author_id == recipient.person.id
      return unless recipient.has_contact_for?(sender)
    end
    super(recipient, sender)
  end

  def comment_email_subject
    I18n.t('reshares.comment_email_subject', :resharer => author.name, :author => root.author.name)
  end

  def notification_type(user, person)
    Notifications::Reshared if root.author == user.person
  end
  
  private

  def after_parse
    root_author = Webfinger.new(@root_diaspora_id).fetch
    root_author.save! unless root_author.persisted?

    return if Post.exists?(:guid => self.root_guid)

    fetched_post = self.class.fetch_post(root_author, self.root_guid)

    #Why are we checking for this?
    if root_author.diaspora_handle != fetched_post.diaspora_handle
      raise "Diaspora ID (#{fetched_post.diaspora_handle}) in the root does not match the Diaspora ID (#{root_author.diaspora_handle}) specified in the reshare!"
    end

    fetched_post.save!
  end

  # Fetch a remote public post, used for receiving reshares of unknown posts
  # @param [Person] author the remote post's author
  # @param [String] guid the remote post's guid
  # @return [Post] an unsaved remote post
  def self.fetch_post author, guid
    response = Faraday.new(author.url + "/p/#{guid}.xml", :ssl => { :verify => false }).get
    Diaspora::Parser.from_xml(response.body)
  end

  def root_must_be_public
    if self.root && !self.root.public
      errors[:base] << "you must reshare public posts"
      return false
    end
  end
end
