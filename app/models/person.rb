#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'uri'
require File.join(Rails.root, 'lib/hcard')

class Person < ActiveRecord::Base
  include ROXML
  include Encryptor::Public
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include Diaspora::Socketable
  include Diaspora::Guid

  xml_attr :diaspora_handle
  xml_attr :url
  xml_attr :profile, :as => Profile
  xml_attr :exported_key

  has_one :profile
  delegate :last_name, :to => :profile

  before_save :downcase_diaspora_handle
  def downcase_diaspora_handle
    diaspora_handle.downcase!
  end

  has_many :contacts #Other people's contacts for this person
  has_many :posts #his own posts

  belongs_to :owner, :class_name => 'User'

  has_many :notification_actors
  has_many :notifications, :through => :notification_actors

  has_many :mentions, :dependent => :destroy

  before_destroy :remove_all_traces
  before_validation :clean_url

  validates_presence_of :url, :profile, :serialized_public_key
  validates_uniqueness_of :diaspora_handle, :case_sensitive => false

  scope :searchable, joins(:profile).where(:profiles => {:searchable => true})

  def self.search(query, user)
    return [] if query.to_s.blank? || query.to_s.length < 3

    where_clause = <<-SQL
      profiles.first_name LIKE ? OR
      profiles.last_name LIKE ? OR
      people.diaspora_handle LIKE ? OR
      profiles.first_name LIKE ? OR
      profiles.last_name LIKE ?
    SQL
    sql = ""
    tokens = []

    query_tokens = query.to_s.strip.split(" ")
    query_tokens.each_with_index do |raw_token, i|
      token = "#{raw_token}%"
      up_token = "#{raw_token.titleize}%"
      sql << " OR " unless i == 0
      sql << where_clause
      tokens.concat([token, token, token])
      tokens.concat([up_token, up_token])
    end
#SELECT `people`.* FROM people
#  INNER JOIN `profiles` ON `profiles`.person_id = `people`.id
#  LEFT OUTER JOIN `contacts` ON (`contacts`.user_id = #{user.id} AND `contacts`.person_id = `people`.id)
#  WHERE `profiles`.searchable = true AND
#  `profiles`.first_name LIKE '%Max%'
#  ORDER BY `contacts`.user_id DESC
    Person.searchable.where(sql, *tokens).joins(
      "LEFT OUTER JOIN `contacts` ON `contacts`.user_id = #{user.id} AND `contacts`.person_id = `people`.id"
    ).joins("LEFT OUTER JOIN `requests` ON `requests`.recipient_id = #{user.person.id} AND `requests`.sender_id = `people`.id"
    ).order("contacts.user_id DESC", "requests.recipient_id DESC", "profiles.last_name ASC", "profiles.first_name ASC")
  end

  def name(opts = {})
    @name ||= if profile.nil? || profile.first_name.nil? || profile.first_name.blank?
                self.diaspora_handle
              else
                "#{profile.first_name.to_s} #{profile.last_name.to_s}"
              end
  end

  def first_name
    @first_name ||= if profile.nil? || profile.first_name.nil? || profile.first_name.blank?
                self.diaspora_handle.split('@').first
              else
                profile.first_name.to_s
              end
  end

  def owns?(post)
    self == post.person
  end

  def url
    begin
      uri = URI.parse(@attributes['url'])
      url = "#{uri.scheme}://#{uri.host}"
      url += ":#{uri.port}" unless ["80", "443"].include?(uri.port.to_s)
      url += "/"
    rescue Exception => e
      url = @attributes['url']
    end
    url
  end

  def receive_url
    "#{url}receive/users/#{self.guid}/"
  end

  def public_url
    "#{url}public/#{self.owner.username}"
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
    serialized_public_key = new_key
  end

  #database calls
  def self.by_account_identifier(identifier)
    identifier = identifier.strip.downcase.gsub('acct:', '')
    self.where(:diaspora_handle => identifier).first
  end

  def self.local_by_account_identifier(identifier)
    person = self.by_account_identifier(identifier)
   (person.nil? || person.remote?) ? nil : person
  end

  def self.create_from_webfinger(profile, hcard)
    return nil if profile.nil? || !profile.valid_diaspora_profile?
    new_person = Person.new
    new_person.serialized_public_key = profile.public_key
    new_person.guid = profile.guid
    new_person.diaspora_handle = profile.account
    new_person.url = profile.seed_location

    #hcard_profile = HCard.find profile.hcard.first[:href]
    Rails.logger.info("event=webfinger_marshal valid=#{new_person.valid?} target=#{new_person.diaspora_handle}")
    new_person.url = hcard[:url]
    new_person.profile = Profile.new(:first_name => hcard[:given_name],
                              :last_name  => hcard[:family_name],
                              :image_url  => hcard[:photo],
                              :image_url_medium  => hcard[:photo_medium],
                              :image_url_small  => hcard[:photo_small],
                              :searchable => hcard[:searchable])
    new_person.save!
    new_person.profile.save!
    new_person
  end

  def remote?
    owner_id.nil?
  end
  def local?
    !remote?
  end

  def as_json(opts={})
   {:id => self.guid, :name => self.name, :avatar => self.profile.image_url(:thumb_small), :handle => self.diaspora_handle, :url => "/people/#{self.id}"}
  end

  protected

  def clean_url
    self.url ||= "http://localhost:3000/" if self.class == User
    if self.url
      self.url = 'http://' + self.url unless self.url.match(/https?:\/\//)
      self.url = self.url + '/' if self.url[-1, 1] != '/'
    end
  end

  private
  def remove_all_traces
    Notification.joins(:notification_actors).where(:notification_actors => {:person_id => self.id}).all.each{ |n| n.destroy}
  end
end
