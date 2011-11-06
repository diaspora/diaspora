#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'diaspora', 'redis_cache')

module Diaspora
  module UserModules
    module Querying

      def find_visible_shareable_by_id(klass, id, opts={} )
        key = opts.delete(:key) || :id
        post = klass.where(key => id).joins(:contacts).where(:contacts => {:user_id => self.id}).where(opts).select(klass.table_name+".*").first
        post ||= klass.where(key => id, :author_id => self.person.id).where(opts).first
        post ||= klass.where(key => id, :public => true).where(opts).first
      end

      def visible_shareables(klass, opts={})
        opts = prep_opts(klass, opts)
        shareable_ids = visible_shareable_ids(klass, opts)
        klass.where(:id => shareable_ids).select('DISTINCT '+klass.to_s.tableize+'.*').limit(opts[:limit]).order(opts[:order_with_table])
      end

      def visible_shareable_ids(klass, opts={})
        opts = prep_opts(klass, opts)
        cache = nil

        if use_cache?(opts)
          cache = RedisCache.new(self, opts[:order_field])

          #cache.ensure_populated!(opts)
          name = klass.to_s.downcase
          shareable_ids = cache.send(name+"_ids", opts[:max_time], opts[:limit])
        end

        if perform_db_query?(shareable_ids, cache, opts)
          visible_ids_from_sql(klass, opts)
        else
          shareable_ids
        end
      end

      # @return [Array<Integer>]
      def visible_ids_from_sql(klass, opts={})
        opts = prep_opts(klass, opts)
        klass.connection.select_values(visible_shareable_sql(klass, opts)).map { |id| id.to_i }
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
        conditions = {:pending => false, :share_visibilities => {:hidden => opts[:hidden]}, :contacts => {:user_id => self.id} }
        conditions[:type] = opts[:type] if opts.has_key?(:type)
        query = opts[:klass].joins(:contacts).where(conditions)

        if opts[:by_members_of]
          query = query.joins(:contacts => :aspect_memberships).where(
            :aspect_memberships => {:aspect_id => opts[:by_members_of]})
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
        self.shareables_from(Post, person)
      end

      def photos_from(person)
        self.shareables_from(Photo, person)
      end

      def shareables_from(klass, person)
        return self.person.send(klass.table_name).where(:pending => false).order("#{klass.table_name}.created_at DESC") if person == self.person
        con = Contact.arel_table
        p = klass.arel_table
        shareable_ids = []
        if contact = self.contact_for(person)
          shareable_ids = klass.connection.select_values(
            contact.share_visibilities.where(:hidden => false, :shareable_type => klass.to_s).select('share_visibilities.shareable_id').to_sql
          )
        end
        shareable_ids += klass.connection.select_values(
          person.send(klass.table_name).where(:public => true).select(klass.table_name+'.id').to_sql
        )

        klass.where(:id => shareable_ids, :pending => false).select('DISTINCT '+klass.table_name+'.*').order(klass.table_name+".created_at DESC")
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
    end
  end
end
