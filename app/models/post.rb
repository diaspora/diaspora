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

  attr_accessor :user_like

  xml_attr :provider_display_name

  has_many :mentions, :dependent => :destroy

  has_many :reshares, :class_name => "Reshare", :foreign_key => :root_guid, :primary_key => :guid
  has_many :resharers, :class_name => 'Person', :through => :reshares, :source => :author

  belongs_to :o_embed_cache
  belongs_to :open_graph_cache

  after_commit :on => :create do
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


  scope :commented_by, ->(person)  {
    select('DISTINCT posts.*')
      .joins(:comments)
      .where(:comments => {:author_id => person.id})
  }

  scope :liked_by, ->(person) {
    joins(:likes).where(:likes => {:author_id => person.id})
  }

  def self.newer(post)
    where("posts.created_at > ?", post.created_at).reorder('posts.created_at ASC').first
  end

  def self.older(post)
    where("posts.created_at < ?", post.created_at).reorder('posts.created_at DESC').first
  end

  def self.visible_from_author(author, current_user=nil)
    if current_user.present?
      current_user.posts_from(author)
    else
      author.posts.all_public
    end
  end

  def post_type
    self.class.name
  end

  def root; end
  def raw_message; ""; end
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

  def reshare_for(user)
    return unless user
    reshares.where(:author_id => user.person.id).first
  end

  def like_for(user)
    return unless user
    likes.where(:author_id => user.person.id).first
  end

  #############

  def self.diaspora_initialize(params)
    new_post = self.new params.to_hash.stringify_keys.slice(*self.column_names)
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

  def comment_email_subject
    I18n.t('notifier.a_post_you_shared')
  end

  def nsfw
    self.author.profile.nsfw?
  end

  def self.find_by_guid_or_id_with_user(id, user=nil)
    key = id.to_s.length <= 8 ? :id : :guid
    post = if user
             user.find_visible_shareable_by_id(Post, id, :key => key)
           else
             Post.where(key => id).includes(:author, :comments => :author).first
           end

    # is that a private post?
    raise(Diaspora::NonPublic) unless user || post.try(:public?)

    post || raise(ActiveRecord::RecordNotFound.new("could not find a post with id #{id}"))
  end
end
