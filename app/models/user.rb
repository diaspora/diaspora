class User < Person
  include MongoMapper::Document
  
  timestamps!
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  before_save :do_bad_things
  
  def do_bad_things
    self.password_confirmation = self.password
  end
end
