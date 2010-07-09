class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  
  validates_presence_of :profile
  
  before_validation :do_bad_things


  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    c = Comment.new(:person_id => self.id, :text => text, :post => options[:on])
    if c.save
      if mine?(c.post)
        c.push_to(c.post.people_with_permissions)  # should return plucky query
      else
        c.push_to([c.post.person])
      end
      true
    end
    false
  end

  ######### Friend Requesting
  def send_friend_request_to(friend_url)
    p = Request.instantiate(:to => friend_url, :from => self)
    if p.save
      p.push_to_url friend_url
    end
  end

  def accept_friend_request(friend_request_id)
    request = Request.where(:id => friend_request_id).first
    request.activate_friend
    request.person = self
    request.push_to(self.callback_url)
    request.destroy
  end

  def receive_friend_request(friend_request)
    if Request.where(:callback_url => friend_request.callback_url).first
      friend_request.activate_friend
      friend_request.destroy
    else
      friend_request.save
    end
  end
 

  def mine?(post)
    self == post.person
  end

  private
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  
end
