# frozen_string_literal: true

module EvilQuery
  class Base
    include Diaspora::Logging

    def fetch_ids!(relation, id_column)
      #the relation should be ordered and limited by here
      @class.connection.select_values(id_sql(relation, id_column))
    end

    def id_sql(relation, id_column)
      @class.connection.unprepared_statement { relation.select(id_column).to_sql }
    end
  end

  class Participation < Base
    def initialize(user)
      @user = user
      @class = Post
    end

    def posts
      author_id = @user.person_id
      Post.joins("LEFT OUTER JOIN participations ON participations.target_id = posts.id AND " \
                 "participations.target_type = 'Post'")
          .where(::Participation.arel_table[:author_id].eq(author_id).or(Post.arel_table[:author_id].eq(author_id)))
          .order("posts.interacted_at DESC")
          .distinct
    end
  end

  class LikedPosts < Base
    def initialize(user)
      @user = user
    end

    def posts
      Post.liked_by(@user.person)
    end
  end

  class CommentedPosts < Base
    def initialize(user)
      @user = user
    end

    def posts
      Post.commented_by(@user.person)
    end
  end

  class MultiStream < Base
    def initialize(user, order, max_time, include_spotlight)
      @user = user
      @class = Post
      @order = order
      @max_time = max_time
      @include_spotlight = include_spotlight
    end

    def make_relation!
      logger.debug("[EVIL-QUERY] make_relation!")
      post_ids = aspects_post_ids! + ids!(followed_tags_posts!) + ids!(mentioned_posts)
      post_ids += ids!(community_spotlight_posts!) if @include_spotlight
      Post.where(:id => post_ids)
    end

    def aspects_post_ids!
      logger.debug("[EVIL-QUERY] aspect_post_ids!")
      @user.visible_shareable_ids(Post, limit: 15, order: "#{@order} DESC", max_time: @max_time, all_aspects?: true)
    end

    def followed_tags_posts!
      logger.debug("[EVIL-QUERY] followed_tags_posts!")
      StatusMessage.public_tag_stream(@user.followed_tag_ids).excluding_hidden_content(@user)
    end

    def mentioned_posts
      logger.debug("[EVIL-QUERY] mentioned_posts")
      StatusMessage.where_person_is_mentioned(@user.person)
    end

    def community_spotlight_posts!
      Post.all_public.where(:author_id => fetch_ids!(Person.community_spotlight, 'people.id'))
    end

    def ids!(query)
      fetch_ids!(query.for_a_stream(@max_time, @order), 'posts.id')
    end
  end

  class VisibleShareableById < Base
    def initialize(user, klass, key, id, conditions={})
      @querent = user
      @class = klass
      @key = key
      @id  = id
      @conditions = conditions
    end

    def post!
      #small optimization - is this optimal order??
      querent_has_visibility.first || querent_is_author.first || public_post.first
    end

    protected

    def querent_has_visibility
      @class.where(@key => @id).joins(:share_visibilities)
        .where(share_visibilities: {user_id: @querent.id})
        .where(@conditions)
        .select(@class.table_name + ".*")
    end

    def querent_is_author
      @class.where(@key => @id, :author_id => @querent.person.id).where(@conditions)
    end

    def public_post
      @class.where(@key => @id, :public => true).where(@conditions)
    end
  end
end
