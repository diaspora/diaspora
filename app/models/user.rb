class User
  include MongoMapper::Document

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         

  #before_validation_on_create :assign_key
  
  before_validation :do_bad_things

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  key :friend_ids, Array
  key :pending_friend_ids, Array


  def friends
    Person.all(:id => self.friend_ids)
  end

  def pending_friends
    Person.all(:id => self.pending_friend_ids)
  end


  def real_name
    "#{person.profile.first_name.to_s} #{person.profile.last_name.to_s}"
  end
  
  



  ######### Friend Requesting
  def send_friend_request_to(friend_url)
    unless Person.where(:url => friend_url).first
      p = Request.instantiate(:to => friend_url, :from => self)
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
    request.exported_key = self.export_key
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
    Rails.logger.info("receiving friend request #{friend_request.to_json}")
    GPGME.import(friend_request.exported_key)
    if Request.where(:callback_url => friend_request.callback_url).first
      friend_request.activate_friend
      friend_request.destroy
    else
      friend_request.person.save
      friend_request.save
    end
  end

  def unfriend(friend_id)
    bad_friend = Person.first(:id => friend_id)


    puts bad_friend.users.count

    self.friend_ids.delete( friend_id )
    self.save



    puts bad_friend.users.count
    
    if bad_friend 
      Retraction.for(self).push_to_url(bad_friend.url) 
      bad_friend.destroy if bad_friend.users.count == 0
    end
  end

  def send_request(rel_hash)
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend])
    else
      raise "you can't do anything to that url"
    end
  end

  
  ###Helpers############
  def mine?(post)
    self == post.person
  end

  def terse_url
    terse= self.url.gsub(/https?:\/\//, '')
    terse.gsub!(/www\./, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end
 
  def do_bad_things
    self.password_confirmation = self.password
  end
  
  def self.owner
    User.first
  end
  
  protected
  
  def assign_key
    keys = GPGME.list_keys(self.real_name, true)
    if keys.empty?
      generate_key
    end
    self.key_fingerprint = GPGME.list_keys(self.real_name, true).first.subkeys.first.fingerprint
  end

  def generate_key
    puts "Generating key"
    puts paramstring
    ctx = GPGME::Ctx.new
    ctx.genkey(paramstring, nil, nil)
    
  end

  def paramstring
"<GnupgKeyParms format=\"internal\">
Key-Type: DSA
Key-Length: 512
Subkey-Type: ELG-E
Subkey-Length: 512
Name-Real: #{self.real_name}
Name-Comment: #{self.url}
Name-Email: #{self.email}
Expire-Date: 0
</GnupgKeyParms>"

  end
end
