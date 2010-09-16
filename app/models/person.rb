#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


require File.expand_path('../../../lib/hcard', __FILE__)

class Person
  include MongoMapper::Document
  include ROXML
  include Encryptor::Public

  xml_accessor :_id
  xml_accessor :diaspora_handle
  xml_accessor :url
  xml_accessor :profile, :as => Profile
  xml_reader :exported_key

  key :url,            String
  key :diaspora_handle, String, :unique => true
  key :serialized_key, String

  key :owner_id,  ObjectId

  one :profile, :class_name => 'Profile'
  many :albums, :class_name => 'Album', :foreign_key => :person_id
  belongs_to :owner, :class_name => 'User'

  timestamps!

  before_destroy :remove_all_traces
  before_validation :clean_url
  validates_presence_of :url, :profile, :serialized_key
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix


  def self.search(query)
    Person.all('$where' => "function() { return this.diaspora_handle.match(/^#{query}/i) ||
               this.profile.first_name.match(/^#{query}/i) ||
               this.profile.last_name.match(/^#{query}/i); }")
  end

  def real_name
    "#{profile.first_name.to_s} #{profile.last_name.to_s}"
  end
  def owns?(post)
    self.id == post.person.id
  end

  def receive_url
    "#{self.url}receive/users/#{self.id}/"
  end

  def encryption_key
    OpenSSL::PKey::RSA.new( serialized_key )
  end

  def encryption_key= new_key
    raise TypeError unless new_key.class == OpenSSL::PKey::RSA
    serialized_key = new_key.export
  end

  def public_key_hash
    Base64.encode64 OpenSSL::Digest::SHA256.new(self.exported_key).to_s
  end

  def public_key
    encryption_key.public_key
  end

  def exported_key
    encryption_key.public_key.export
  end

  def exported_key= new_key
    raise "Don't change a key" if serialized_key
    @serialized_key = new_key
  end

  def self.by_webfinger( identifier )
    local_person = Person.first(:diaspora_handle => identifier.gsub('acct:', ''))

     if local_person
       local_person
     elsif  !identifier.include?("localhost")
       begin
        f = Redfinger.finger(identifier)
       rescue SocketError => e
         raise "Diaspora server for #{identifier} not found" if e.message =~ /Name or service not known/
       end
       raise "No webfinger profile found at #{identifier}" unless f
       Person.from_webfinger_profile(identifier, f )
     end
  end

  def self.from_webfinger_profile( identifier, profile)
    new_person = Person.new

    public_key = profile.links.select{|x| x.rel == 'diaspora-public-key'}.first.href
    new_person.exported_key = Base64.decode64 public_key

    guid = profile.links.select{|x| x.rel == 'http://joindiaspora.com/guid'}.first.href
    new_person.id = guid

    new_person.diaspora_handle = identifier

    hcard = HCard.find profile.hcard.first[:href]

    new_person.url = hcard[:url]
    new_person.profile = Profile.new(:first_name => hcard[:given_name], :last_name => hcard[:family_name])
    if new_person.save
      new_person
    else
      nil
    end
  end

  def remote?
    owner.nil?
  end

  def as_json(opts={})
    {
      :person => {
        :id           => self.id,
        :name         => self.real_name,
        :diaspora_handle        => self.diaspora_handle,
        :url          => self.url,
        :exported_key => exported_key
      }
    }
  end

  protected
  def clean_url
    self.url ||= "http://localhost:3000/" if self.class == User
    if self.url
      self.url = 'http://' + self.url unless self.url.match('http://' || 'https://')
      self.url = self.url + '/' if self.url[-1,1] != '/'
    end
  end

  private
  def remove_all_traces
    Post.all(:person_id => id).each{|p| p.delete}
    Album.all(:person_id => id).each{|p| p.delete}
  end
end
