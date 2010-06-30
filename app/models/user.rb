class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  

  def comment(text, options = {})
    raise "Comment on what, motherfucker?" unless options[:on]
    c = Comment.new(:person_id => self.id, :text => text, :post => options[:on])
    if c.save
      if mine?(c.post)
        c.push_to(c.post.friends_with_permissions)  # should return plucky query
      else
        c.push_to([c.post.person])
      end
      true
    end
    false
  end
  
  validates_presence_of :profile
  
  before_validation :do_bad_things
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  def mine?(post)
    self == post.person
  end
  
end
