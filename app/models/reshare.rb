class Reshare < Post 

  belongs_to :root, :class_name => 'Post'
  validate :root_must_be_public
  attr_accessible :root_id, :public

  xml_attr :root_diaspora_id
  xml_attr :root_guid

  before_validation do 
    self.public = true
  end

  def root_guid
    self.root.guid  
  end

  def root_diaspora_id
    self.root.author.diaspora_handle
  end

  def receive(user, person)
    local_reshare = Reshare.where(:guid => self.guid).first
    if local_reshare.root.author_id == user.person.id
      local_reshare.root.reshares << local_reshare
      
      if user.contact_for(person)
        local_reshare.receive(user, person)
      end

    else
      super(user, person)
    end
  end

  private

  def after_parse
    root_author = Webfinger.new(@root_diaspora_id).fetch
    root_author.save!

    local_post = Post.where(:guid => @root_guid).select('id').first

    unless local_post && self.root_id = local_post.id
      received_post = Diaspora::Parser.from_xml(Faraday.get(root_author.url + "/p/#{@root_guid}.xml").body)
      unless post = received_post.class.where(:guid => received_post.guid).first
        post = received_post

        if root_author.diaspora_handle != post.diaspora_handle
          raise "Diaspora ID (#{post.diaspora_handle}) in the root does not match the Diaspora ID (#{root_author.diaspora_handle}) specified in the reshare!"
        end

        post.author_id = root_author.id
        post.save!
      end

      self.root_id = post.id
    end
  end

  def root_must_be_public
    if self.root.nil? || !self.root.public
      errors[:base] << "you must reshare public posts"
      return false
    end
  end
end
