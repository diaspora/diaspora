#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'uri'
require File.join(Rails.root, 'lib/hcard')

class Person < ActiveRecord::Base
  include ROXML
  include Encryptor::Public
  include Diaspora::Guid

  xml_attr :diaspora_handle
  xml_attr :url
  xml_attr :profile, :as => Profile
  xml_attr :exported_key

  has_one :profile, :dependent => :destroy
  delegate :last_name, :to => :profile
  accepts_nested_attributes_for :profile

  before_validation :downcase_diaspora_handle
  def downcase_diaspora_handle
    diaspora_handle.downcase! unless diaspora_handle.blank?
  end

  has_many :contacts, :dependent => :destroy # Other people's contacts for this person
  has_many :posts, :foreign_key => :author_id, :dependent => :destroy # This person's own posts
  has_many :photos, :foreign_key => :author_id, :dependent => :destroy # This person's own photos
  has_many :comments, :foreign_key => :author_id, :dependent => :destroy # This person's own comments

  belongs_to :owner, :class_name => 'User'

  has_many :notification_actors
  has_many :notifications, :through => :notification_actors

  has_many :mentions, :dependent => :destroy

  before_destroy :remove_all_traces
  before_validation :clean_url

  validates :url, :presence => true
  validates :profile, :presence => true
  validates :serialized_public_key, :presence => true
  validates :diaspora_handle, :uniqueness => true

  scope :searchable, joins(:profile).where(:profiles => {:searchable => true})
  scope :remote, where('people.owner_id IS NULL')
  scope :local, where('people.owner_id IS NOT NULL')
  scope :for_json, select('DISTINCT people.id, people.diaspora_handle').includes(:profile)

  # @note user is passed in here defensively
  scope :all_from_aspects, lambda { |aspect_ids, user|
    joins(:contacts => :aspect_memberships).
         where(:contacts => {:user_id => user.id},
               :aspect_memberships => {:aspect_id => aspect_ids}).
         select("DISTINCT people.*")
  }

  scope :profile_tagged_with, lambda{|tag_name| joins(:profile => :tags).where(:profile => {:tags => {:name => tag_name}}).where('profiles.searchable IS TRUE') }

  scope :who_have_reshared_a_users_posts, lambda{|user| 
    joins(:posts).where(:posts => {:root_guid => StatusMessage.guids_for_author(user.person), :type => 'Reshare'} )
  }

  def self.community_spotlight
    AppConfig[:community_spotlight].present? ? Person.where(:diaspora_handle => AppConfig[:community_spotlight]) : []
  end

  # Set a default of an empty profile when a new Person record is instantiated.
  # Passing :profile => nil to Person.new will instantiate a person with no profile.
  # Calling Person.new with a block:
  #   Person.new do |p|
  #     p.profile = nil
  #   end
  # will not work!  The nil profile will be overriden with an empty one.
  def initialize(params={})
    profile_set = params.has_key?(:profile) || params.has_key?("profile")
    params[:profile_attributes] = params.delete(:profile) if params.has_key?(:profile) && params[:profile].is_a?(Hash)
    super
    self.profile ||= Profile.new unless profile_set
  end

  def self.find_from_id_or_username(params)
    p = if params[:id].present?
          Person.where(:id => params[:id]).first
        elsif params[:username].present? && u = User.find_by_username(params[:username])
          u.person
        else
          nil
        end
    raise ActiveRecord::RecordNotFound unless p.present?
    p
  end

  def self.search_query_string(query)
    query = query.downcase
    like_operator = postgres? ? "ILIKE" : "LIKE"

    where_clause = <<-SQL
      profiles.full_name #{like_operator} ? OR
      people.diaspora_handle #{like_operator} ?
    SQL

    q_tokens = []
    q_tokens[0] = query.to_s.strip.gsub(/(\s|$|^)/) { "%#{$1}" }
    q_tokens[1] = q_tokens[0].gsub(/\s/,'').gsub('%','')
    q_tokens[1] << "%"

    [where_clause, q_tokens]
  end

  def self.search(query, user)
    return self.where("1 = 0") if query.to_s.blank? || query.to_s.length < 2

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
    first_name.blank? && last_name.blank? ? diaspora_handle : "#{first_name.to_s.strip} #{last_name.to_s.strip}".strip
  end

  def first_name
    @first_name ||= if profile.nil? || profile.first_name.nil? || profile.first_name.blank?
                self.diaspora_handle.split('@').first
              else
                names = profile.first_name.to_s.split(/\s/)
                str = names[0...-1].join(' ')
                str = names[0] if str.blank?
                str
              end
  end

  def owns?(obj)
    self.id == obj.author_id
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
    self.photos.exists?
  end

  def as_json( opts = {} )
    opts ||= {}
    json = {
      :id => self.id,
      :name => self.name,
      :avatar => self.profile.image_url(:thumb_medium),
      :handle => self.diaspora_handle,
      :url => "/people/#{self.id}",
    }
    json.merge!(:tags => self.profile.tags.map{|t| "##{t.name}"}) if opts[:includes] == "tags"
    json
  end

  # Update an array of people given a url, and set it as the new destination_url
  # @param people [Array<People>]
  # @param url [String]
  def self.url_batch_update(people, url)
    people.each do |person|
      person.update_url(url)
    end 
  end

  # @param person [Person]
  # @param url [String]
  def update_url(url)
    location = URI.parse(url)
    newuri = "#{location.scheme}://#{location.host}"
    newuri += ":#{location.port}" unless ["80", "443"].include?(location.port.to_s)
    newuri += "/"
    self.update_attributes(:url => newuri)
  end

  def lock_access!
    self.closed_account = true
    self.save
  end

  def clear_profile!
    self.profile.tombstone!
    self
  end

  protected

  def clean_url
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
