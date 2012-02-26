#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  include ApplicationHelper

  include Diaspora::Federated::Shareable

  include Diaspora::Likeable
  include Diaspora::Commentable
  include Diaspora::Shareable


  has_many :participations, :dependent => :delete_all, :as => :target

  attr_accessor :user_like,
                :user_participation

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add lambda { |post|
      post.raw_message
    }, :as => :text
    t.add :public
    t.add :created_at
    t.add :interacted_at
    t.add :comments_count
    t.add :likes_count
    t.add :reshares_count
    t.add :last_three_comments
    t.add :provider_display_name
    t.add :author
    t.add :post_type
    t.add :image_url
    t.add :object_url
    t.add :root
    t.add :o_embed_cache
    t.add :user_like
    t.add :user_participation
    t.add :mentioned_people
    t.add :photos
    t.add :nsfw
  end

  xml_attr :provider_display_name

  has_many :mentions, :dependent => :destroy

  has_many :reshares, :class_name => "Reshare", :foreign_key => :root_guid, :primary_key => :guid
  has_many :resharers, :class_name => 'Person', :through => :reshares, :source => :author

  belongs_to :o_embed_cache

  after_create do
    self.touch(:interacted_at)
  end

  #scopes
  scope :includes_for_a_stream, includes(:o_embed_cache, {:author => :profile}, :mentions => {:person => :profile}) #note should include root and photos, but i think those are both on status_message


  scope :commented_by, lambda { |person|
    select('DISTINCT posts.*').joins(:comments).where(:comments => {:author_id => person.id})
  }

  scope :liked_by, lambda { |person|
    joins(:likes).where(:likes => {:author_id => person.id})
  }

  def post_type
    self.class.name
  end

  def raw_message; ""; end
  def mentioned_people; []; end
  def photos; []; end

  def self.excluding_blocks(user)
    people = user.blocks.map{|b| b.person_id}
    scope = scoped

    if people.any?
      scope = scope.where("posts.author_id NOT IN (?)", people)
    end

    scope
  end

  def self.excluding_hidden_shareables(user)
    scope = scoped
    if user.has_hidden_shareables_of_type?
      scope = scope.where('posts.id NOT IN (?)', user.hidden_shareables["#{self.base_class}"])
    end
    scope
  end

  def self.excluding_hidden_content(user)
    excluding_blocks(user).excluding_hidden_shareables(user)
  end

  def self.for_a_stream(max_time, order, user=nil)
    scope = self.for_visible_shareable_sql(max_time, order).
      includes_for_a_stream

    scope = scope.excluding_hidden_content(user) if user.present?

    scope
  end

  #############

  def self.diaspora_initialize(params)
    new_post = self.new params.to_hash
    new_post.author = params[:author]
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
    new_post.diaspora_handle = new_post.author.diaspora_handle
    new_post
  end

  # @return Returns true if this Post will accept updates (i.e. updates to the caption of a photo).
  def mutable?
    false
  end

  def activity_streams?
    false
  end

  def triggers_caching?
    true
  end

  def comment_email_subject
    I18n.t('notifier.a_post_you_shared')
  end

  def nsfw
    self.author.profile.nsfw?
  end
end
