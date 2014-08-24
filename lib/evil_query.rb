module EvilQuery
  class Base
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
      Post.joins(:participations).where(:participations => {:author_id => @user.person.id}).order("posts.interacted_at DESC")
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
      Rails.logger.debug("[EVIL-QUERY] make_relation!")
      post_ids = aspects_post_ids! + ids!(followed_tags_posts!) + ids!(mentioned_posts)
      post_ids += ids!(community_spotlight_posts!) if @include_spotlight
      Post.where(:id => post_ids)
    end

    def aspects_post_ids!
      Rails.logger.debug("[EVIL-QUERY] aspect_post_ids!")
      @user.visible_shareable_ids(Post, :limit => 15, :order => "#{@order} DESC", :max_time => @max_time, :all_aspects? => true, :by_members_of => @user.aspect_ids)
    end

    def followed_tags_posts!
      Rails.logger.debug("[EVIL-QUERY] followed_tags_posts!")
      StatusMessage.public_tag_stream(@user.followed_tag_ids)
    end

    def mentioned_posts
      Rails.logger.debug("[EVIL-QUERY] mentioned_posts")
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
      querent_is_contact.first || querent_is_author.first || public_post.first
    end

    protected

    def querent_is_contact
      @class.where(@key => @id).joins(:contacts).where(:contacts => {:user_id => @querent.id}).where(@conditions).select(@class.table_name+".*")
    end

    def querent_is_author
      @class.where(@key => @id, :author_id => @querent.person.id).where(@conditions)
    end

    def public_post
      @class.where(@key => @id, :public => true).where(@conditions)
    end
  end

  class ShareablesFromPerson < Base
    def initialize(querent, klass, person)
      @querent = querent
      @class = klass
      @person = person
    end

    def make_relation!
      return querents_posts if @person == @querent.person

      # persons_private_visibilities and persons_public_posts have no limit which is making shareable_ids gigantic.
      # perhaps they should the arrays should be merged and sorted
      # then the query at the bottom of this method can be paginated or something?

      shareable_ids = contact.present? ? fetch_ids!(persons_private_visibilities, "share_visibilities.shareable_id") : []
      shareable_ids += fetch_ids!(persons_public_posts, table_name + ".id")

      @class.where(:id => shareable_ids, :pending => false).
          select('DISTINCT '+table_name+'.*').
          order(table_name+".created_at DESC")
    end

    protected

    def table_name
      @class.table_name
    end

    def contact
      @contact ||= @querent.contact_for(@person)
    end

    def querents_posts
      @querent.person.send(table_name).where(:pending => false).order("#{table_name}.created_at DESC")
    end

    def persons_private_visibilities
      contact.share_visibilities.where(:hidden => false, :shareable_type => @class.to_s)
    end

    def persons_public_posts
      @person.send(table_name).where(:public => true).select(table_name+'.id')
    end
  end
end
