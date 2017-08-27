# frozen_string_literal: true

#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# the point of this object is to centralize the simmilarities of Photo and Post,
# as they used to be the same class
module Diaspora
  module Shareable
    def self.included(model)
      model.instance_eval do
        include Diaspora::Fields::Guid
        include Diaspora::Fields::Author

        has_many :aspect_visibilities, as: :shareable, validate: false, dependent: :delete_all
        has_many :aspects, through: :aspect_visibilities

        has_many :share_visibilities, as: :shareable, dependent: :delete_all

        delegate :id, :name, :first_name, to: :author, prefix: true

        # scopes
        scope :with_visibility, -> {
          joins("LEFT OUTER JOIN share_visibilities ON share_visibilities.shareable_id = #{table_name}.id AND "\
            "share_visibilities.shareable_type = '#{base_class}'")
        }

        scope :with_aspects, -> {
          joins("LEFT OUTER JOIN aspect_visibilities ON aspect_visibilities.shareable_id = #{table_name}.id AND "\
          " aspect_visibilities.shareable_type = '#{base_class}'")
        }
      end
      model.extend Diaspora::Shareable::QueryMethods
    end

    def receive(recipient_user_ids)
      return if recipient_user_ids.empty? || public?

      ShareVisibility.batch_import(recipient_user_ids, self)
    end

    # The list of people that should receive this Shareable.
    #
    # @return [Array<Person>] The list of subscribers to this shareable
    def subscribers
      user = author.owner
      if public?
        [*user.contact_people, author]
      else
        user.people_in_aspects(user.aspects_with_shareable(self.class, id))
      end
    end

    # Remote pods which are known to be subscribed to the post. Must include all pods which received the post in the
    # past.
    #
    # @return [Array<String>] The list of pods' URIs
    def subscribed_pods_uris
      Pod.find(subscribers.select(&:remote?).map(&:pod_id).uniq).map {|pod| pod.url_to("") }
    end

    module QueryMethods
      def owned_or_visible_by_user(user)
        with_visibility.where(
          visible_by_user(user).or(arel_table[:public].eq(true)
                                     .or(arel_table[:author_id].eq(user.person_id)))
        ).select("DISTINCT #{table_name}.*")
      end

      def from_person_visible_by_user(user, person)
        return owned_by_user(user) if person == user.person

        with_visibility.where(author_id: person.id).where(
          visible_by_user(user).or(arel_table[:public].eq(true))
        ).select("DISTINCT #{table_name}.*")
      end

      def for_visible_shareable_sql(max_time, order, limit=15, types=Stream::Base::TYPES_OF_POST_IN_STREAM)
        by_max_time(max_time, order).order(table_name + ".id DESC").where(type: types).limit(limit)
      end

      def by_max_time(max_time, order="created_at")
        where("#{table_name}.#{order} < ?", max_time).order("#{table_name}.#{order} DESC")
      end

      def owned_by_user(user)
        user.person.public_send(table_name)
      end

      private

      def visible_by_user(user)
        ShareVisibility.arel_table[:user_id].eq(user.id)
      end
    end
  end
end
