class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  
  #before_create :assign_key
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
    unless Person.where(:url => friend_url).first
      p = Request.instantiate(:to => friend_url, :from => self)
      puts p.inspect
      if p.save
        p.push_to_url friend_url
      end
      p
    end
  end 

  def accept_friend_request(friend_request_id)
    request = Request.where(:id => friend_request_id).first
    request.activate_friend
    request.person = self
    request.destination_url = request.callback_url
    request.push_to_url(request.callback_url)
    request.destroy
  end

  def ignore_friend_request(friend_request_id)
    request = Request.first(:id => friend_request_id)
    person = request.person
    person.destroy unless person.active
    request.destroy
  end

  def receive_friend_request(friend_request)
    if Request.where(:callback_url => friend_request.callback_url).first
      friend_request.activate_friend
      friend_request.destroy
    else
      friend_request.person.save
      friend_request.save
    end
  end

  def unfriend(friend_id)
    bad_friend  = Person.first(:id => friend_id, :active => true)
    if bad_friend 
       Retraction.for(self).push_to_url(bad_friend.url) 
       bad_friend.destroy
    end
  end

  
  ###Helpers############
  def mine?(post)
    self == post.person
  end
 
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  def self.owner
    User.first
  end
  
  protected
  
  def assign_key
    keys = GPGME.list_keys(nil, true)
    if keys.empty?
      generate_key
    end
    self.key_fingerprint = GPGME.list_keys(nil, true).first.subkeys.first.fingerprint
  end

  def generate_key
    puts "Generating key"
    ctx = GPGME::Ctx.new
    paramstring = "<GnupgKeyParms format=\"internal\">
Key-Type: DSA
Key-Length: 512
Subkey-Type: ELG-E
Subkey-Length: 512
Name-Real: #{self.real_name}
Name-Comment: #{self.url}
Name-Email: #{self.email}
Expire-Date: 0
</GnupgKeyParms>"
    ctx.genkey(paramstring, nil, nil)
    
  end
end
