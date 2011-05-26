class Reshare < Post 
  belongs_to :root, :class_name => 'Post'
  validate :root_must_be_public
  attr_accessible :root_id, :public

  before_validation do 
    self.public = true
  end


  delegate :photos, :text, :comments, :to => :root
  private

  def root_must_be_public
    if self.root.nil? || !self.root.public
      errors[:base] << "you must reshare public posts"
      return false
    end
  end
end
