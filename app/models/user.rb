class User < Person
  require 'lib/diaspora/ostatus_parser'
  include Diaspora::OStatusParser

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  
  before_validation_on_create :assign_key
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
    bad_friend  = Person.first(:id => friend_id, :active => true)
    if bad_friend 
       Retraction.for(self).push_to_url(bad_friend.url) 
       bad_friend.destroy
    end
  end

  ####ostatus######
  #
  def subscribe_to_pubsub(feed_url)
    r = Request.instantiate(:to => feed_url, :from => self)
    r.subscribe_to_ostatus(feed_url)
    r
  end

  def unsubscribe_from_pubsub(author_id)
    bad_author = Author.first(:id => author_id)
    r = Request.instantiate(:to => bad_author.hub, :from => self)
    r.unsubscribe_from_ostatus(bad_author.feed_url)
    bad_author.destroy
  end


  def send_request(rel_hash)
    puts rel_hash.inspect
    if rel_hash[:friend]
      self.send_friend_request_to(rel_hash[:friend])
    elsif rel_hash[:subscribe]
      self.subscribe_to_pubsub(rel_hash[:subscribe])
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
    keys = GPGME.list_keys(real_name, true)
    if keys.empty?
      generate_key
    end
    self.key_fingerprint = GPGME.list_keys(real_name, true).first.subkeys.first.fingerprint
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
