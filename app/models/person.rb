#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/hcard')

class Person
  include MongoMapper::Document
  include ROXML
  include Encryptor::Public

  xml_accessor :_id
  xml_accessor :diaspora_handle
  xml_accessor :url
  xml_accessor :profile, :as => Profile
  xml_reader :exported_key

  key :url, String
  key :diaspora_handle, String, :unique => true
  key :serialized_public_key, String

  key :owner_id, ObjectId

  one :profile, :class_name => 'Profile'
  validate :profile_is_valid
  def profile_is_valid
    if profile.present? && !profile.valid?
      profile.errors.full_messages.each { |m| errors.add(:base, m) }
    end
  end

  many :albums, :class_name => 'Album', :foreign_key => :person_id
  belongs_to :owner, :class_name => 'User'

  timestamps!
  
  before_destroy :remove_all_traces
  before_validation :clean_url
  validates_presence_of :url, :profile, :serialized_public_key
  validates_format_of :url, :with =>
    /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix

  def self.search(query)
    return Person.all if query.to_s.empty?
    query_tokens = query.to_s.strip.split(" ")
    full_query_text = Regexp.escape(query.to_s.strip)

    p = []

    query_tokens.each do |token|
      q = Regexp.escape(token.to_s.strip)
      p = Person.all('profile.first_name' => /^#{q}/i) \
 | Person.all('profile.last_name' => /^#{q}/i) \
 | p
    end
  
    return p
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

  def public_url
    "#{self.url}public/#{self.owner.username}"
  end


  def public_key_hash
    Base64.encode64 OpenSSL::Digest::SHA256.new(self.exported_key).to_s
  end

  def public_key
    OpenSSL::PKey::RSA.new(serialized_public_key)
  end

  def exported_key
    serialized_public_key
  end

  def exported_key= new_key
    raise "Don't change a key" if serialized_public_key
    @serialized_public_key = new_key
  end

  def self.by_webfinger(identifier, opts = {})
    # Raise an error if identifier has a port number 
    raise "Identifier is invalid" if(identifier.strip.match(/\:\d+$/))
    # Raise an error if identifier is not a valid email (generous regexp)
    raise "Identifier is invalid" if !(identifier =~ /\A.*\@.*\..*\Z/)

    query = /#{Regexp.escape(identifier.gsub('acct:', '').to_s)}/i
    local_person = Person.first(:diaspora_handle => query)
    
    if local_person
      Rails.logger.info("Do not need to webfinger, found a local person #{local_person.real_name}")
      local_person
    elsif  !identifier.include?("localhost") && !opts[:local]
      #Get remote profile
      begin
        Rails.logger.info("Webfingering #{identifier}")
        f = Redfinger.finger(identifier)
      rescue SocketError => e
        raise "Diaspora server for #{identifier} not found" if e.message =~ /Name or service not known/
      rescue Errno::ETIMEDOUT => e
        raise "Connection timed out to Diaspora server for #{identifier}"
      end
      raise "No webfinger profile found at #{identifier}" if f.nil? || f.links.empty?
      Person.from_webfinger_profile(identifier, f)
    end
  end

  def self.from_webfinger_profile(identifier, profile)
    new_person = Person.new

    public_key_entry = profile.links.select { |x| x.rel == 'diaspora-public-key' }

    return nil unless public_key_entry

    pubkey = public_key_entry.first.href
    new_person.exported_key = Base64.decode64 pubkey

    guid = profile.links.select { |x| x.rel == 'http://joindiaspora.com/guid' }.first.href
    new_person.id = guid

    new_person.diaspora_handle = identifier

    hcard = HCard.find profile.hcard.first[:href]

    new_person.url = hcard[:url]
    new_person.profile = Profile.new(:first_name => hcard[:given_name], :last_name => hcard[:family_name], :image_url => hcard[:photo])
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
      self.url = self.url + '/' if self.url[-1, 1] != '/'
    end
  end

  private
  def remove_all_traces
    Post.all(:person_id => id).each { |p| p.delete }
  end

end
