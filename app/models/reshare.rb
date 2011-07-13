class Reshare < Post 
  belongs_to :root, :class_name => 'Post'
  validate :root_must_be_public
  attr_accessible :root_id, :public

  before_validation do 
    self.public = true
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

  def root_must_be_public
    if self.root.nil? || !self.root.public
      errors[:base] << "you must reshare public posts"
      return false
    end
  end
end
