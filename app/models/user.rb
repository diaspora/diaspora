class User < Person
  include MongoMapper::Document
  
  timestamps!
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
         
  def comment(text, options = {})
    raise "Comment on what, motherfucker?" unless options[:on]
    Comment.new(:person_id => self.id, :text => text, :post => options[:on]).save
  end
  
  
  before_validation :do_bad_things
  def do_bad_things
    self.password_confirmation = self.password
  end
end
