#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  self.include_root_in_json = false

  include ApplicationHelper

  include Diaspora::Federated::Base

  include Diaspora::Likeable
  include Diaspora::Commentable
  include Diaspora::Shareable

  has_many :participations, dependent: :delete_all, as: :target, inverse_of: :target
  has_many :participants, class_name: "Person", through: :participations, source: :author

  attr_accessor :user_like

  has_many :reports, as: :item

  has_many :mentions, dependent: :destroy

  has_many :reshares, class_name: "Reshare", foreign_key: :root_guid, primary_key: :guid
  has_many :resharers, class_name: "Person", through: :reshares, source: :author

  belongs_to :o_embed_cache
  belongs_to :open_graph_cache

  validates_uniqueness_of :id

  after_create do
    self.touch(:interacted_at)
  end

  #scopes
  scope :includes_for_a_stream, -> {
    includes(:o_embed_cache,
             :open_graph_cache,
             {:author => :profile},
             :mentions => {:person => :profile}
    ) #note should include root and photos, but i think those are both on status_message
  }

  scope :all_public, -> { where(public: true) }

  scope :commented_by, ->(person)  {
    select('DISTINCT posts.*')
      .joins(:comments)
      .where(:comments => {:author_id => person.id})
  }

  scope :liked_by, ->(person) {
    joins(:likes).where(:likes => {:author_id => person.id})
  }

  def post_type
    self.class.name
  end

  def root; end
  def mentioned_people; []; end
  def photos; []; end

  #prevents error when trying to access @post.address in a post different than Reshare and StatusMessage types;
  #check PostPresenter
  def address
  end

  def poll
  end

  def self.excluding_blocks(user)
    people = user.blocks.map{|b| b.person_id}
    scope = all

    if people.any?
      scope = scope.where("posts.author_id NOT IN (?)", people)
    end

    scope
  end

  def self.excluding_hidden_shareables(user)
    scope = all
    if user.has_hidden_shareables_of_type?
      scope = scope.where('posts.id NOT IN (?)', user.hidden_shareables["#{self.base_class}"])
    end
    scope
  end

  def self.excluding_hidden_content(user)
    excluding_blocks(user).excluding_hidden_shareables(user)
  end

  def self.for_a_stream(max_time, order, user=nil, ignore_blocks=false)
    scope = self.for_visible_shareable_sql(max_time, order).
      includes_for_a_stream

    if user.present?
      if ignore_blocks
        scope = scope.excluding_hidden_shareables(user)
      else
        scope = scope.excluding_hidden_content(user)
      end
    end

    scope
  end

  def reshare_for(user)
    return unless user
    reshares.where(:author_id => user.person.id).first
  end

  def like_for(user)
    return unless user
    likes.where(:author_id => user.person.id).first
  end

  #############

  # @return [Integer]
  def update_reshares_counter
    self.class.where(id: id).update_all(reshares_count: reshares.count)
  end

  def self.diaspora_initialize(params)
    new(params.to_hash.stringify_keys.slice(*column_names, "author"))
  end

  def comment_email_subject
    I18n.t('notifier.a_post_you_shared')
  end

  def nsfw
    self.author.profile.nsfw?
  end

  def subscribers
    super.tap do |subscribers|
      subscribers.concat(resharers).concat(participants) if public?
    end
  end
end
