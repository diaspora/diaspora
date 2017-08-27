# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Person < ApplicationRecord
  include Diaspora::Fields::Guid

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

  has_one :profile, dependent: :destroy
  delegate :last_name, :full_name, :image_url, :tag_string, :bio, :location,
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
  has_many :likes, foreign_key: :author_id, dependent: :destroy # This person's own likes
  has_many :participations, :foreign_key => :author_id, :dependent => :destroy
  has_many :poll_participations, foreign_key: :author_id, dependent: :destroy
  has_many :conversation_visibilities, dependent: :destroy
  has_many :messages, foreign_key: :author_id, dependent: :destroy
  has_many :conversations, foreign_key: :author_id, dependent: :destroy
  has_many :blocks, dependent: :destroy

  has_many :roles

  belongs_to :owner, class_name: "User", optional: true
  belongs_to :pod, optional: true

  has_many :notification_actors
  has_many :notifications, :through => :notification_actors

  has_many :mentions, :dependent => :destroy

  validate :owner_xor_pod
  validate :other_person_with_same_guid, on: :create
  validates :profile, :presence => true
  validates :serialized_public_key, :presence => true
  validates :diaspora_handle, :uniqueness => true

  scope :searchable, -> (user) {
    joins(:profile).where("profiles.searchable = true OR contacts.user_id = ?", user.id)
  }
  scope :remote, -> { where('people.owner_id IS NULL') }
  scope :local, -> { where('people.owner_id IS NOT NULL') }
  scope :for_json, -> { select("people.id, people.guid, people.diaspora_handle").includes(:profile) }

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
    joins(contacts: :aspect_memberships)
      .where(aspect_memberships: {aspect_id: aspect_ids}).distinct
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

  # This scope selects people where the full name contains the search_str or diaspora ID
  # starts with the search_str.
  # However, if the search_str doesn't have more than 1 non-whitespace character, it'll return an empty set.
  # @param [String] search substring
  # @return [Person::ActiveRecord_Relation]
  scope :find_by_substring, ->(search_str) {
    search_str = search_str.strip
    if search_str.blank? || search_str.size < 2
      none
    else
      sql, tokens = search_query_string(search_str)
      joins(:profile).where(sql, *tokens)
    end
  }

  # Left joins likes and comments to a specific post where people are authors of these comments and likes
  # @param [String, Integer] post ID for which comments and likes should be joined
  # @return [Person::ActiveRecord_Relation]
  scope :left_join_visible_post_interactions_on_authorship, ->(post_id) {
    comments_sql = <<-SQL
      LEFT OUTER JOIN comments ON
      comments.author_id = people.id AND comments.commentable_type = 'Post' AND comments.commentable_id = #{post_id}
    SQL

    likes_sql = <<-SQL
      LEFT OUTER JOIN likes ON
      likes.author_id = people.id AND likes.target_type = 'Post' AND likes.target_id = #{post_id}
    SQL

    joins(comments_sql).joins(likes_sql)
  }

  # Selects people who can be mentioned in a comment to a specific post. For public posts all people
  # are allowed, so no additional constraints are added. For private posts selection is limited to
  # people who have posted comments or likes for this post.
  # @param [Post] the post for which we query mentionable in comments people
  # @return [Person::ActiveRecord_Relation]
  scope :allowed_to_be_mentioned_in_a_comment_to, ->(post) {
    allowed = if post.public?
                all
              else
                left_join_visible_post_interactions_on_authorship(post.id)
                  .where("comments.id IS NOT NULL OR likes.id IS NOT NULL OR people.id = #{post.author_id}")
              end
    allowed.distinct
  }

  # This scope adds sorting of people in the order, appropriate for suggesting to a user (current user) who
  # has requested a list of the people mentionable in a comment for a specific post.
  # Sorts people in the following priority: post author > commenters > likers > contacts > non-contacts
  # @param [Post] post for which the mentionable in comment people list is requested
  # @param [User] user who requests the people list
  # @return [Person::ActiveRecord_Relation]
  scope :sort_for_mention_suggestion, ->(post, user) {
    left_join_visible_post_interactions_on_authorship(post.id)
      .joins("LEFT OUTER JOIN contacts ON people.id = contacts.person_id AND contacts.user_id = #{user.id}")
      .joins(:profile)
      .select(<<-SQL
        people.id = #{unscoped { post.author_id }} AS is_author,
        comments.id IS NOT NULL AS is_commenter,
        likes.id IS NOT NULL AS is_liker,
        contacts.id IS NOT NULL AS is_contact
        SQL
             )
      .order(<<-SQL
        is_author DESC,
        is_commenter DESC,
        is_liker DESC,
        is_contact DESC,
        profiles.full_name,
        people.diaspora_handle
        SQL
            )
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
          Person.find_by(guid: params[:id])
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

  private_class_method def self.search_query_string(query)
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

  def self.search(search_str, user, only_contacts: false, mutual: false)
    query = find_by_substring(search_str)
    return query if query.is_a?(ActiveRecord::NullRelation)

    query = if only_contacts
              query.joins(:contacts).where(contacts: {user_id: user.id})
            else
              query.joins(
                "LEFT OUTER JOIN contacts ON contacts.user_id = #{user.id} AND contacts.person_id = people.id"
              ).searchable(user)
            end

    query = query.where(contacts: {sharing: true, receiving: true}) if mutual

    query.where(closed_account: false)
         .order(["contacts.user_id IS NULL", "profiles.last_name ASC", "profiles.first_name ASC"])
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

  def author
    self
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

  # @param path [String]
  # @return [String]
  def url_to(path)
    local? ? AppConfig.url_to(path) : pod.url_to(path)
  end

  def public_key_hash
    Base64.encode64(OpenSSL::Digest::SHA256.new(serialized_public_key).to_s)
  end

  def public_key
    OpenSSL::PKey::RSA.new(serialized_public_key)
  rescue OpenSSL::PKey::RSAError
    nil
  end

  def exported_key
    serialized_public_key
  end

  # discovery (webfinger)
  def self.find_or_fetch_by_identifier(diaspora_id)
    # exiting person?
    person = by_account_identifier(diaspora_id)
    return person if person.present? && person.profile.present?

    # create or update person from webfinger
    logger.info "webfingering #{diaspora_id}, it is not known or needs updating"
    DiasporaFederation::Discovery::Discovery.new(diaspora_id).fetch_and_save

    by_account_identifier(diaspora_id)
  end

  def self.by_account_identifier(diaspora_id)
    find_by(diaspora_handle: diaspora_id.strip.downcase)
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
      id:     id,
      guid:   guid,
      name:   name,
      avatar: profile.image_url(:thumb_small),
      handle: diaspora_handle,
      url:    Rails.application.routes.url_helpers.person_path(self)
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

  def fix_profile
    logger.info "fix profile for account: #{diaspora_handle}"
    DiasporaFederation::Discovery::Discovery.new(diaspora_handle).fetch_and_save
    reload
  end

  def owner_xor_pod
    errors.add(:base, "Specify an owner or a pod, not both") unless owner.blank? ^ pod.blank?
  end

  def other_person_with_same_guid
    diaspora_id = Person.where(guid: guid).where.not(diaspora_handle: diaspora_handle).pluck(:diaspora_handle).first
    errors.add(:base, "Person with same GUID already exists: #{diaspora_id}") if diaspora_id
  end
end
