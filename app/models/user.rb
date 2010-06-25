class User < Person
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  def post(post_type, options)
    case post_type
    when :status_message
      StatusMessage.new(:person => self, :message => options[:message]).save
    else
      raise "Not a type I can post yet"
    end
  end
end
