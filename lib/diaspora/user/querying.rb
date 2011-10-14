#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'diaspora', 'redis_cache')

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id, opts={} )
        key = opts.delete(:key) || :id
        post = Post.where(key => id).joins(:contacts).where(:contacts => {:user_id => self.id}).where(opts).select("posts.*").first
        post ||= Post.where(key => id, :author_id => self.person.id).where(opts).first
        post ||= Post.where(key => id, :public => true).where(opts).first
      end

      def visible_posts(opts={})
        opts = prep_opts(opts)
        post_ids = visible_post_ids(opts)
        Post.where(:id => post_ids).select('DISTINCT posts.*').limit(opts[:limit]).order(opts[:order_with_table])
      end

      def visible_post_ids(opts={})
        opts = prep_opts(opts)

        if RedisCache.configured? && RedisCache.supported_order?(opts[:order_field]) && opts[:all_aspects?].present?
          cache = RedisCache.new(self, opts[:order_field])

          cache.ensure_populated!(opts)
          post_ids = cache.post_ids(opts[:max_time], opts[:limit])
        end

        if post_ids.blank? || post_ids.length < opts[:limit]
          visible_ids_from_sql(opts)
        else
          post_ids
        end
      end

      # @return [Array<Integer>]
      def visible_ids_from_sql(opts={})
        opts = prep_opts(opts)
        Post.connection.select_values(visible_posts_sql(opts)).map { |id| id.to_i }
      end

      def visible_posts_sql(opts={})
        opts = prep_opts(opts)
        select_clause ='DISTINCT posts.id, posts.updated_at AS updated_at, posts.created_at AS created_at'

        posts_from_others = Post.joins(:contacts).where( :pending => false, :type => opts[:type], :post_visibilities => {:hidden => opts[:hidden]}, :contacts => {:user_id => self.id})
        posts_from_self = self.person.posts.where(:pending => false, :type => opts[:type])

        if opts[:by_members_of]
          posts_from_others = posts_from_others.joins(:contacts => :aspect_memberships).where(
            :aspect_memberships => {:aspect_id => opts[:by_members_of]})
          posts_from_self = posts_from_self.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => opts[:by_members_of]})
        end

        posts_from_others = posts_from_others.select(select_clause).order(opts[:order_with_table]).where(Post.arel_table[opts[:order_field]].lt(opts[:max_time]))
        posts_from_self = posts_from_self.select(select_clause).order(opts[:order_with_table]).where(Post.arel_table[opts[:order_field]].lt(opts[:max_time]))

        "(#{posts_from_others.to_sql} LIMIT #{opts[:limit]}) UNION ALL (#{posts_from_self.to_sql} LIMIT #{opts[:limit]}) ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"
      end

      def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
      end
      def aspects_with_post(post_id)
        self.aspects.joins(:aspect_visibilities).where(:aspect_visibilities => {:post_id => post_id})
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
        person_ids = contacts_in_aspects(allowed_aspects).collect{|contact| contact.person_id}
        people = Person.where(:id => person_ids)

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

      def contacts_in_aspects aspects
        aspects.inject([]) do |contacts,aspect|
          contacts | aspect.contacts
        end
      end

      def posts_from(person)
        return self.person.posts.where(:pending => false).order("created_at DESC") if person == self.person
        con = Contact.arel_table
        p = Post.arel_table
        post_ids = []
        if contact = self.contact_for(person)
          post_ids = Post.connection.select_values(
            contact.post_visibilities.where(:hidden => false).select('post_visibilities.post_id').to_sql
          )
        end
        post_ids += Post.connection.select_values(
          person.posts.where(:public => true).select('posts.id').to_sql
        )

        Post.where(:id => post_ids, :pending => false).select('DISTINCT posts.*').order("posts.created_at DESC")
      end

      protected

      # @return [Hash]
      def prep_opts(opts)
        defaults = {
          :type => Stream::Base::TYPES_OF_POST_IN_STREAM, 
          :order => 'created_at DESC',
          :limit => 15,
          :hidden => false
        }
        opts = defaults.merge(opts)

        opts[:order_field] = opts[:order].split.first.to_sym
        opts[:order_with_table] = 'posts.' + opts[:order]

        opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
        opts[:max_time] ||= Time.now + 1
        opts
      end
    end
  end
end
