#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id, opts={} )
        post = Post.where(:id => id).joins(:contacts).where(:contacts => {:user_id => self.id}).where(opts).first
        post ||= Post.where(:id => id, :author_id => self.person.id).where(opts).first
        post ||= Post.where(:id => id, :public => true).where(opts).first
      end

      def visible_posts(opts = {})
        defaults = {
          :type => ['StatusMessage', 'Photo'],
          :order => 'updated_at DESC',
          :limit => 15,
          :hidden => false
        }
        opts = defaults.merge(opts)

        order_field = opts[:order].split.first.to_sym
        order_with_table = 'posts.' + opts[:order]

        opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
        opts[:max_time] ||= Time.now + 1

        select_clause ='DISTINCT posts.id, posts.updated_at AS updated_at, posts.created_at AS created_at'

        posts_from_others = Post.joins(:contacts).where( :pending => false, :type => opts[:type], :post_visibilities => {:hidden => opts[:hidden]}, :contacts => {:user_id => self.id})
        posts_from_self = self.person.posts.where(:pending => false, :type => opts[:type])

        if opts[:by_members_of]
          posts_from_others = posts_from_others.joins(:contacts => :aspect_memberships).where(
            :aspect_memberships => {:aspect_id => opts[:by_members_of]})
          posts_from_self = posts_from_self.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => opts[:by_members_of]})
        end

        posts_from_others = posts_from_others.select(select_clause).limit(opts[:limit]).order(order_with_table).where(Post.arel_table[order_field].lt(opts[:max_time]))
        posts_from_self = posts_from_self.select(select_clause).limit(opts[:limit]).order(order_with_table).where(Post.arel_table[order_field].lt(opts[:max_time]))

        all_posts = "(#{posts_from_others.to_sql}) UNION ALL (#{posts_from_self.to_sql}) ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"

        post_ids = Post.connection.execute(all_posts).map {|post| id_for(post) }

        Post.where(:id => post_ids).select('DISTINCT posts.*').limit(opts[:limit]).order(order_with_table)
      end

      # Determine, cache, and execute the method call needed to extract the id from a raw result row.
      # Returns row["id"] for PostgreSQL
      # Returns row.first for everything else (MYSQL)
      #
      # @param row The row to get the id from.
      # @return The id of the database row passed in.
      def id_for row
        @@id_method_for_row ||= if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
                                  [:[], "id"]
                                else
                                  :first
                                end
        row.send(*@@id_method_for_row)
      end

      def visible_photos(opts = {})
        visible_posts(opts.merge(:type => 'Photo'))
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

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end

      def posts_from(person)
        return self.person.posts.where(:pending => false).order("created_at DESC") if person == self.person
        con = Contact.arel_table
        p = Post.arel_table
        post_ids = []
        if contact = self.contact_for(person)
          post_ids = Post.connection.execute(contact.post_visibilities.where(:hidden => false).select('post_visibilities.post_id').to_sql).map{|r| r.first}
        end
        post_ids += Post.connection.execute(person.posts.where(:public => true).select('posts.id').to_sql).map{|r| r.first}

        Post.where(:id => post_ids, :pending => false).select('DISTINCT posts.*').order("posts.created_at DESC")
      end
    end
  end
end
