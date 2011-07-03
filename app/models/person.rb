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

  has_one :profile, :dependent => :destroy
  delegate :last_name, :to => :profile

  before_validation :downcase_diaspora_handle
  def downcase_diaspora_handle
    diaspora_handle.downcase! unless diaspora_handle.blank?
  end

  has_many :contacts, :dependent => :destroy #Other people's contacts for this person
  has_many :posts, :foreign_key => :author_id, :dependent => :destroy #his own posts
  has_many :comments, :foreign_key => :author_id, :dependent => :destroy #his own comments

  belongs_to :owner, :class_name => 'User'

  has_many :notification_actors
  has_many :notifications, :through => :notification_actors

  has_many :mentions, :dependent => :destroy

  before_destroy :remove_all_traces
  before_validation :clean_url

  validates_presence_of :url, :profile, :serialized_public_key
  validates_uniqueness_of :diaspora_handle

  scope :searchable, joins(:profile).where(:profiles => {:searchable => true})

  def self.search_query_string(query)
    if postgres?
      where_clause = <<-SQL
        profiles.first_name ILIKE ? OR
        profiles.last_name ILIKE ? OR
        people.diaspora_handle ILIKE ?
      SQL
    else
      where_clause = <<-SQL
        profiles.first_name LIKE ? OR
        profiles.last_name LIKE ? OR
        people.diaspora_handle LIKE ? OR
        profiles.first_name LIKE ? OR
        profiles.last_name LIKE ?
      SQL
    end

    sql = ""
    tokens = []

    query_tokens = query.to_s.strip.split(" ")
    query_tokens.each_with_index do |raw_token, i|
      token = "#{raw_token}%"
      up_token = "#{raw_token.titleize}%"
      sql << " OR " unless i == 0
      sql << where_clause
      tokens.concat([token, token, token])
      tokens.concat([up_token, up_token]) unless postgres?
    end
    [sql, tokens]
  end

  def self.search(query, user)
    return [] if query.to_s.blank? || query.to_s.length < 3

    sql, tokens = self.search_query_string(query)
    Person.searchable.where(sql, *tokens).joins(
      "LEFT OUTER JOIN contacts ON contacts.user_id = #{user.id} AND contacts.person_id = people.id"
    ).includes(:profile
    ).order(search_order)
  end

  # @return [Array<String>] postgreSQL and mysql deal with null values in orders differently, it seems.
  def self.search_order
    @search_order ||= Proc.new {
      order = if postgres?
        "ASC"
      else
        "DESC"
      end
      ["contacts.user_id #{order}", "profiles.last_name ASC", "profiles.first_name ASC"]
    }.call
  end



  def self.public_search(query, opts={})
    return [] if query.to_s.blank? || query.to_s.length < 3
    sql, tokens = self.search_query_string(query)
    Person.searchable.where(sql, *tokens)
  end

  def name(opts = {})
    if self.profile.nil?
      fix_profile
    end
    @name ||= Person.name_from_attrs(self.profile.first_name, self.profile.last_name, self.diaspora_handle)
  end

  def self.name_from_attrs(first_name, last_name, diaspora_handle)
    first_name.blank? ? diaspora_handle : "#{first_name.to_s} #{last_name.to_s}"
  end

  def first_name
    @first_name ||= if profile.nil? || profile.first_name.nil? || profile.first_name.blank?
                self.diaspora_handle.split('@').first
              else
                profile.first_name.to_s
              end
  end

  def owns?(obj)
    self == obj.author
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
    if self.owner
      username = self.owner.username
    else
      username = self.diaspora_handle.split("@")[0]
    end
    "#{url}public/#{username}"
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
    new_person.assign_new_profile_from_hcard(hcard)
    new_person.save!
    new_person.profile.save!
    new_person
  end

  def assign_new_profile_from_hcard(hcard)
    self.profile = Profile.new(:first_name => hcard[:given_name],
                              :last_name  => hcard[:family_name],
                              :image_url  => hcard[:photo],
                              :image_url_medium  => hcard[:photo_medium],
                              :image_url_small  => hcard[:photo_small],
                              :searchable => hcard[:searchable])
  end

  def remote?
    owner_id.nil?
  end
  def local?
    !remote?
  end

  def has_photos?
    self.posts.where(:type => "Photo").exists?
  end

  def as_json(opts={})
    json = {
      :id => self.id,
      :name => self.name,
      :avatar => self.profile.image_url(:thumb_small),
      :handle => self.diaspora_handle,
      :url => "/people/#{self.id}"
    }
    json.merge(:aspect_ids => opts[:aspect_ids])
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

  def fix_profile
    Webfinger.new(self.diaspora_handle).fetch
    self.reload
  end
end
