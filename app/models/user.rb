class User < Person

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  

  def comment(text, options = {})
    raise "Comment on what, motherfucker?" unless options[:on]
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
  
  before_create :assign_key

  validates_presence_of :profile
  
  before_validation :do_bad_things
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  def mine?(post)
    self == post.person
  end

  protected
  
  def assign_key
    keys = GPGME.list_keys(nil, true)
    if keys.empty?
      generate_key
    end
    self.key_fingerprint = GPGME.list_keys(nil, true).first.subkeys.first.fingerprint
    puts self.key_fingerprint
  end

  def generate_key
    puts "Yo, generating a key."
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
Passphrase: #{self.password}
</GnupgKeyParms>"
    ctx.genkey(paramstring, nil, nil)
    
  end
end
