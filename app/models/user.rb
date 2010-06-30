class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  

  def comment(text, options = {})
    raise "Comment on what, motherfucker?" unless options[:on]
    Comment.new(:person_id => self.id, :text => text, :post => options[:on]).save
  end
  
  validates_presence_of :profile
  
  before_validation :do_bad_things
  def do_bad_things
    self.password_confirmation = self.password
  end
end
