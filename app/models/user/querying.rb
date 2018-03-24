# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#TODO: THIS FILE SHOULD NOT EXIST, EVIL SQL SHOULD BE ENCAPSULATED IN EvilQueries,
#throwing all of this stuff in user violates demeter like WHOA
module User::Querying
  def find_visible_shareable_by_id(klass, id, opts={} )
    key = (opts.delete(:key) || :id)
    ::EvilQuery::VisibleShareableById.new(self, klass, key, id, opts).post!
  end

  def visible_shareables(klass, opts={})
    opts = prep_opts(klass, opts)
    shareable_ids = visible_shareable_ids(klass, opts)
    klass.where(id: shareable_ids).select("DISTINCT #{klass.table_name}.*")
      .limit(opts[:limit]).order(opts[:order_with_table])
  end

  def visible_shareable_ids(klass, opts={})
    visible_ids_from_sql(klass, prep_opts(klass, opts))
  end

  def contact_for(person)
    return nil unless person
    contact_for_person_id(person.id)
  end

  def block_for(person)
    return nil unless person
    blocks.find_by(person_id: person.id)
  end

  def aspects_with_shareable(base_class_name_or_class, shareable_id)
    base_class_name = base_class_name_or_class
    base_class_name = base_class_name_or_class.base_class.to_s if base_class_name_or_class.is_a?(Class)
    self.aspects.joins(:aspect_visibilities).where(:aspect_visibilities => {:shareable_id => shareable_id, :shareable_type => base_class_name})
  end

  def contact_for_person_id(person_id)
    Contact.includes(person: :profile).find_by(user_id: id, person_id: person_id)
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
    Post.from_person_visible_by_user(self, person).order("posts.created_at desc")
  end

  def photos_from(person, opts={})
    opts = prep_opts(Photo, opts)
    Photo.from_person_visible_by_user(self, person)
      .by_max_time(opts[:max_time])
      .limit(opts[:limit])
  end

  protected

  # @return [Array<Integer>]
  def visible_ids_from_sql(klass, opts)
    opts[:klass] = klass
    opts[:by_members_of] ||= aspect_ids

    klass.connection.select_values(visible_shareable_sql(opts)).map(&:to_i)
  end

  def visible_shareable_sql(opts)
    shareable_from_others = construct_shareable_from_others_query(opts)
    shareable_from_self = construct_shareable_from_self_query(opts)

    "(#{shareable_from_others.to_sql} LIMIT #{opts[:limit]}) " \
    "UNION ALL (#{shareable_from_self.to_sql} LIMIT #{opts[:limit]}) " \
    "ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"
  end

  def construct_shareable_from_others_query(opts)
    logger.debug "[EVIL-QUERY] user.construct_shareable_from_others_query"

    query = visible_shareables_query(posts_from_aspects_query(opts), opts)

    query = query.where(type: opts[:type]) unless opts[:klass] == Photo

    ugly_select_clause(query, opts)
  end

  # For PostgreSQL and MySQL/MariaDB we use a different query
  # see issue: https://github.com/diaspora/diaspora/issues/5014
  def posts_from_aspects_query(opts)
    if AppConfig.postgres?
      opts[:klass].where(author_id: Person.in_aspects(opts[:by_members_of]).select("people.id"))
    else
      person_ids = Person.connection.select_values(Person.in_aspects(opts[:by_members_of]).select("people.id").to_sql)
      opts[:klass].where(author_id: person_ids)
    end
  end

  def visible_shareables_query(query, opts)
    query.with_visibility.where(
      visible_private_shareables(opts).or(opts[:klass].arel_table[:public].eq(true))
    )
  end

  def visible_private_shareables(opts)
    ShareVisibility.arel_table[:user_id].eq(id)
      .and(ShareVisibility.arel_table[:shareable_type].eq(opts[:klass].to_s))
      .and(ShareVisibility.arel_table[:hidden].eq(opts[:hidden]))
  end

  def construct_shareable_from_self_query(opts)
    conditions = {author_id: person_id}
    conditions[:type] = opts[:type] if opts.has_key?(:type)
    query = opts[:klass].where(conditions)

    unless opts[:all_aspects?]
      query = query.with_aspects.where(
        AspectVisibility.arel_table[:aspect_id].in(opts[:by_members_of])
          .or(opts[:klass].arel_table[:public].eq(true))
      )
    end

    ugly_select_clause(query, opts)
  end

  def ugly_select_clause(query, opts)
    klass = opts[:klass]
    table = klass.table_name
    select_clause = "DISTINCT %s.id, %s.updated_at AS updated_at, %s.created_at AS created_at" % [table, table, table]
    query.select(select_clause).order(opts[:order_with_table])
      .where(klass.arel_table[opts[:order_field]].lt(opts[:max_time]))
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
    if opts[:limit] == :all
      opts.delete(:limit)
    end

    opts[:order_field] = opts[:order].split.first.to_sym
    opts[:order_with_table] = klass.table_name + '.' + opts[:order]

    opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
    opts[:max_time] ||= Time.now + 1
    opts
  end
end
