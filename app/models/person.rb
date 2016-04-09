#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Person < ActiveRecord::Base
  include ROXML
  include Encryptor::Public
  include Diaspora::Guid

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :name
    t.add lambda { |person|
      person.diaspora_handle
    }, :as => :diaspora_id
    t.add lambda { |person|
      {:small => person.profile.image_url(:thumb_small),
       :medium => person.profile.image_url(:thumb_medium),
       :large => person.profile.image_url(:thumb_large) }
    }, :as => :avatar
  end

  xml_attr :diaspora_handle
  xml_attr :url
  xml_attr :profile, :as => Profile
  xml_attr :exported_key

  has_one :profile, dependent: :destroy
  delegate :last_name, :image_url, :tag_string, :bio, :location,
           :gender, :birthday, :formatted_birthday, :tags, :searchable,
           :public_details?, to: :profile
  accepts_nested_attributes_for :profile

  before_validation :downcase_diaspora_handle

  def downcase_diaspora_handle
    diaspora_handle.downcase! unless diaspora_handle.blank?
  end

  has_many :contacts, :dependent => :destroy # Other people's contacts for this person
  has_many :posts, :foreign_key => :author_id, :dependent => :destroy # This person's own posts
  has_many :photos, :foreign_key => :author_id, :dependent => :destroy # This person's own photos
  has_many :comments, :foreign_key => :author_id, :dependent => :destroy # This person's own comments
  has_many :participations, :foreign_key => :author_id, :dependent => :destroy
  has_many :conversation_visibilities

  has_many :roles

  belongs_to :owner, :class_name => 'User'
  belongs_to :pod

  has_many :notification_actors
  has_many :notifications, :through => :notification_actors

  has_many :mentions, :dependent => :destroy

  validate :owner_xor_pod
  validates :profile, :presence => true
  validates :serialized_public_key, :presence => true
  validates :diaspora_handle, :uniqueness => true

  scope :searchable, -> { joins(:profile).where(:profiles => {:searchable => true}) }
  scope :remote, -> { where('people.owner_id IS NULL') }
  scope :local, -> { where('people.owner_id IS NOT NULL') }
  scope :for_json, -> {
    select('DISTINCT people.id, people.guid, people.diaspora_handle')
      .includes(:profile)
  }

  # @note user is passed in here defensively
  scope :all_from_aspects, ->(aspect_ids, user) {
    joins(:contacts => :aspect_memberships).
         where(:contacts => {:user_id => user.id}).
         where(:aspect_memberships => {:aspect_id => aspect_ids})
  }

  scope :unique_from_aspects, ->(aspect_ids, user) {
    all_from_aspects(aspect_ids, user).select('DISTINCT people.*')
  }

  #not defensive
  scope :in_aspects, ->(aspect_ids) {
    joins(:contacts => :aspect_memberships).
        where(:aspect_memberships => {:aspect_id => aspect_ids})
  }

  scope :profile_tagged_with, ->(tag_name) {
    joins(:profile => :tags)
      .where(:tags => {:name => tag_name})
      .where('profiles.searchable IS TRUE')
  }

  scope :who_have_reshared_a_users_posts, ->(user) {
    joins(:posts)
      .where(:posts => {:root_guid => StatusMessage.guids_for_author(user.person), :type => 'Reshare'} )
  }

  def self.community_spotlight
    Person.joins(:roles).where(:roles => {:name => 'spotlight'})
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

  def self.find_from_guid_or_username(params)
    p = if params[:id].present?
          Person.where(:guid => params[:id]).first
        elsif params[:username].present? && u = User.find_by_username(params[:username])
          u.person
        else
          nil
        end
    raise ActiveRecord::RecordNotFound unless p.present?
    p
  end

  def to_param
    self.guid
  end

  def self.search_query_string(query)
    query = query.downcase
    like_operator = AppConfig.postgres? ? "ILIKE" : "LIKE"

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
      order = if AppConfig.postgres?
        "ASC"
      else
        "DESC"
      end
      ["contacts.user_id #{order}", "profiles.last_name ASC", "profiles.first_name ASC"]
    }.call
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

  def username
    @username ||= owner ? owner.username : diaspora_handle.split("@")[0]
  end

  def owns?(obj)
    self.id == obj.author_id
  end

  def url
    url_to "/"
  end

  def profile_url
    url_to "/u/#{username}"
  end

  def atom_url
    url_to "/public/#{username}.atom"
  end

  def receive_url
    url_to "/receive/users/#{guid}"
  end

  def public_key_hash
    Base64.encode64(OpenSSL::Digest::SHA256.new(serialized_public_key).to_s)
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

  # discovery (webfinger)
  def self.find_or_fetch_by_identifier(account)
    # exiting person?
    person = by_account_identifier(account)
    return person if person.present? && person.profile.present?

    # create or update person from webfinger
    logger.info "webfingering #{account}, it is not known or needs updating"
    DiasporaFederation::Discovery::Discovery.new(account).fetch_and_save

    by_account_identifier(account)
  end

  # database calls
  def self.by_account_identifier(identifier)
    identifier = identifier.strip.downcase.sub("acct:", "")
    find_by(diaspora_handle: identifier)
  end

  def self.find_local_by_diaspora_handle(handle)
    where(diaspora_handle: handle, closed_account: false).where.not(owner: nil).take
  end

  def self.find_local_by_guid(guid)
    where(guid: guid, closed_account: false).where.not(owner: nil).take
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
      :guid => self.guid,
      :name => self.name,
      :avatar => self.profile.image_url(:thumb_medium),
      :handle => self.diaspora_handle,
      :url => Rails.application.routes.url_helpers.person_path(self),
    }
    json.merge!(:tags => self.profile.tags.map{|t| "##{t.name}"}) if opts[:includes] == "tags"
    json
  end

  def lock_access!
    self.closed_account = true
    self.save
  end

  def clear_profile!
    self.profile.tombstone!
    self
  end

  private

  # @param path [String]
  # @return [String]
  def url_to(path)
    local? ? AppConfig.url_to(path) : pod.url_to(path)
  end

  def fix_profile
    logger.info "fix profile for account: #{diaspora_handle}"
    DiasporaFederation::Discovery::Discovery.new(diaspora_handle).fetch_and_save
    reload
  end

  def owner_xor_pod
    errors.add(:base, "Specify an owner or a pod, not both") unless owner.blank? ^ pod.blank?
  end
end
