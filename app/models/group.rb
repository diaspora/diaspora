class Group < ActiveRecord::Base
  include Diaspora::Taggable
  include Diaspora::Likeable

  if RUBY_VERSION.include?('1.9')
    VALID_CHARACTERS ="[[:alnum:]]_-"
  else
    VALID_CHARACTERS = "\\w-"
  end

  acts_as_taggable_on :tags
  extract_tags_from :description
  before_create :build_tags
  before_save do |group|
    group.identifier.downcase!
  end

  validates(
    :identifier,
    :presence => true,
    :length => { :maximum => 64 },
    :uniqueness => true,
    :format => { :with => /^[#{VALID_CHARACTERS}]+$/, :message => I18n.t('groups.valid_characters') }
  )
  validates :name, :presence => true, :length => { :maximum => 128 }
  validates :description, :length => { :maximum => 2048 }
  validates :admission, :presence => true, :format => { :with => /^open|on-approval|manual$/ }

  has_many :group_posts
  has_many :posts, :through => :group_posts
  has_many :group_members
  has_many :members, :through => :group_members, :source => :person
  has_many :membership_requests, :class_name => 'GroupMembershipRequest'

  def self.groups_from_string(s)
    groups = []
    pod_host = AppConfig[:pod_uri].host

    s.scan(/!([#{VALID_CHARACTERS}]+)@#{pod_host}/).each do |match|
      groups << Group.find_by_identifier(match[0])
    end

    groups.compact
  end

  def identifier_full
    '!' + self.identifier + '@' + AppConfig[:pod_uri].host
  end

  def has_membership_request_from?(someone)
    if someone.respond_to?(:person)
      person = someone.person
    else
      person = someone
    end

    person && !! membership_requests.find_by_person_id( person.id )
  end

  def image_url_sized(size)
    if image_url
      image_url.gsub  /thumb_(small|medium|large)_/, "thumb_#{size}_"
    end
  end
end
