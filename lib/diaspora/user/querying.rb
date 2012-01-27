#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'diaspora', 'redis_cache')

module Diaspora
  module EvilQuery
    def self.legacy_prep_opts(klass, opts)
      defaults = {
          :order => 'created_at DESC',
          :limit => 15,
          :hidden => false
      }
      defaults[:type] = Stream::Base::TYPES_OF_POST_IN_STREAM if klass == Post
      opts = defaults.merge(opts)

      opts[:order_field] = opts[:order].split.first.to_sym
      opts[:order_with_table] = klass.table_name + '.' + opts[:order]

      opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
      opts[:max_time] ||= Time.now + 1
      opts
    end

    class MultiStream
      def initialize(user, order, max_time, include_spotlight)
        @user = user
        @order = order
        @max_time = max_time
        @aspect_ids = aspect_ids!
        @include_spotlight = include_spotlight
      end

      def aspect_ids!
        @user.aspects.map(&:id)
      end

      def make_relation!
        post_ids = aspects_post_ids + followed_tags_post_ids + mentioned_post_ids
        post_ids += community_spotlight_post_ids if @include_spotlight
        Post.where(:id => post_ids)
      end

      def aspects_post_ids
        @aspects_post_ids ||= @user.visible_shareable_ids(Post, :limit => 15, :order => "#{@order} DESC", :max_time => @max_time, :all_aspects? => true, :by_members_of => @aspect_ids)
      end

      def followed_tags_post_ids
        @followed_tags_ids ||= ids(StatusMessage.public_tag_stream(tag_ids))
      end

      def mentioned_post_ids
        @mentioned_post_ids ||= ids(StatusMessage.where_person_is_mentioned(@user.person))
      end

      def community_spotlight_post_ids
        @community_spotlight_post_ids ||= ids(Post.all_public.where(:author_id => community_spotlight_person_ids))
      end

      def community_spotlight_person_ids
        @community_spotlight_person_ids ||= Person.community_spotlight.select('id').map{|x| x.id}
      end

      def tag_ids
        @user.followed_tags.map{|x| x.id}
      end

      def ids(query)
        Post.connection.select_values(query.for_a_stream(@max_time, @order).select('posts.id').to_sql)
      end
    end

    class Base
      def initialize(user, klass)
        @querent = user
        @class = klass
      end
    end

    class VisibleShareableById < Base
      def initialize(user, klass, key, id, conditions={})
        super(user, klass)
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
        super(querent, klass)
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

      def fetch_ids!(relation, id_column)
        #the relation should be ordered and limited by here
        @class.connection.select_values(relation.select(id_column).to_sql)
      end

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

  module UserModules
    module Querying
      def find_visible_shareable_by_id(klass, id, opts={} )
        key = (opts.delete(:key) || :id)
        EvilQuery::VisibleShareableById.new(self, klass, key, id, opts).post!
      end

      def visible_shareables(klass, opts={})
        opts = prep_opts(klass, opts)
        shareable_ids = visible_shareable_ids(klass, opts)
        klass.where(:id => shareable_ids).select('DISTINCT '+klass.to_s.tableize+'.*').limit(opts[:limit]).order(opts[:order_with_table])
      end

      def visible_shareables_from_cache(klass, opts)
        cache = RedisCache.new(self, opts[:order_field])

        #total hax
        if self.contacts.where(:sharing => true, :receiving => true).count > 0
          cache.ensure_populated!(opts)
        end

        name = klass.to_s.downcase + "_ids"
        cached_ids = cache.send(name, opts[:max_time], opts[:limit] +1)

        if perform_db_query?(cached_ids, cache, opts)
          visible_ids_from_sql(klass, opts)
        else
          cached_ids
        end
      end

      def visible_shareable_ids(klass, opts={})
        opts = prep_opts(klass, opts)
        if use_cache?(opts)
          visible_shareables_from_cache(klass, opts)
        else
          visible_ids_from_sql(klass, opts)
        end
      end

      # @return [Array<Integer>]
      def visible_ids_from_sql(klass, opts={})
        opts = prep_opts(klass, opts)
        opts[:klass] = klass
        opts[:by_members_of] ||= self.aspect_ids

        post_ids = klass.connection.select_values(visible_shareable_sql(klass, opts)).map { |id| id.to_i }
        post_ids += klass.connection.select_values(construct_public_followings_sql(opts).to_sql).map {|id| id.to_i }
      end

      def visible_shareable_sql(klass, opts={})
        table = klass.table_name
        opts = prep_opts(klass, opts)
        opts[:klass] = klass

        shareable_from_others = construct_shareable_from_others_query(opts)
        shareable_from_self = construct_shareable_from_self_query(opts)

        "(#{shareable_from_others.to_sql} LIMIT #{opts[:limit]}) UNION ALL (#{shareable_from_self.to_sql} LIMIT #{opts[:limit]}) ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"
      end

      def ugly_select_clause(query, opts)
        klass = opts[:klass]
        select_clause ='DISTINCT %s.id, %s.updated_at AS updated_at, %s.created_at AS created_at' % [klass.table_name, klass.table_name, klass.table_name]
        query.select(select_clause).order(opts[:order_with_table]).where(klass.arel_table[opts[:order_field]].lt(opts[:max_time]))
      end

      def construct_shareable_from_others_query(opts)
        conditions = {
            :pending => false,
            :share_visibilities => {:hidden => opts[:hidden]},
            :contacts => {:user_id => self.id, :receiving => true}
        }

        conditions[:type] = opts[:type] if opts.has_key?(:type)

        query = opts[:klass].joins(:contacts).where(conditions)

        if opts[:by_members_of]
          query = query.joins(:contacts => :aspect_memberships).where(
            :aspect_memberships => {:aspect_id => opts[:by_members_of]})
        end

        ugly_select_clause(query, opts)
      end

      def construct_public_followings_sql(opts)
        aspects = Aspect.where(:id => opts[:by_members_of])
        person_ids = Person.connection.select_values(people_in_aspects(aspects).select("people.id").to_sql)

        query = opts[:klass].where(:author_id => person_ids, :public => true, :pending => false)

        unless(opts[:klass] == Photo)
          query = query.where(:type => opts[:type])
        end

        ugly_select_clause(query, opts)
      end

      def construct_shareable_from_self_query(opts)
        conditions = {:pending => false }
        conditions[:type] = opts[:type] if opts.has_key?(:type)
        query = self.person.send(opts[:klass].to_s.tableize).where(conditions)

        if opts[:by_members_of]
          query = query.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => opts[:by_members_of]})
        end

        ugly_select_clause(query, opts)
      end

      def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
      end

      def aspects_with_shareable(base_class_name_or_class, shareable_id)
        base_class_name = base_class_name_or_class
        base_class_name = base_class_name_or_class.base_class.to_s if base_class_name_or_class.is_a?(Class)
        self.aspects.joins(:aspect_visibilities).where(:aspect_visibilities => {:shareable_id => shareable_id, :shareable_type => base_class_name})
      end

      def contact_for_person_id(person_id)
        Contact.where(:user_id => self.id, :person_id => person_id).includes(:person => :profile).first
      end

      # @param [Person] person
      # @return [Boolean] whether person is a contact of this user
      def has_contact_for?(person)
        Contact.exists?(:user_id => self.id, :person_id => person.id)
      end

      def people_in_aspects(requested_aspects, opts={})
        allowed_aspects = self.aspects & requested_aspects
        aspect_ids = allowed_aspects.map(&:id)

        people = Person.in_aspects(aspect_ids)

        if opts[:type] == 'remote'
          people = people.where(:owner_id => nil)
        elsif opts[:type] == 'local'
          people = people.where('people.owner_id IS NOT NULL')
        end
        people
      end

      def aspects_with_person person
        contact_for(person).aspects
      end

      def posts_from(person)
        EvilQuery::ShareablesFromPerson.new(self, Post, person).make_relation!
      end

      def photos_from(person)
        EvilQuery::ShareablesFromPerson.new(self, Photo, person).make_relation!
      end

      protected
      # @return [Boolean]

      def use_cache?(opts)
        RedisCache.configured? && RedisCache.supported_order?(opts[:order_field]) && opts[:all_aspects?].present?
      end

      # @return [Boolean]
      def perform_db_query?(shareable_ids, cache, opts)
        return true if cache == nil
        return false if cache.size <= opts[:limit]
        shareable_ids.blank? || shareable_ids.length < opts[:limit]
      end

      # @return [Hash]
      def prep_opts(klass, opts)
        EvilQuery.legacy_prep_opts(klass, opts)
      end
    end
  end
end
