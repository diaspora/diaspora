#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# the point of this object is to centralize the simmilarities of Photo and Post,
# as they used to be the same class
module Diaspora
  module Shareable
    def self.included(model)
      model.instance_eval do
        has_many :aspect_visibilities, as: :shareable, validate: false, dependent: :delete_all
        has_many :aspects, through: :aspect_visibilities

        has_many :share_visibilities, as: :shareable, dependent: :delete_all

        belongs_to :author, class_name: "Person"

        delegate :id, :name, :first_name, to: :author, prefix: true

        # scopes
        scope :all_public, -> { where(public: true, pending: false) }

        scope :with_visibility, -> {
          joins("LEFT OUTER JOIN share_visibilities ON share_visibilities.shareable_id = #{table_name}.id")
        }

        scope :with_aspects, -> {
          joins("LEFT OUTER JOIN aspect_visibilities ON aspect_visibilities.shareable_id = #{table_name}.id")
        }

        def self.owned_or_visible_by_user(user)
          with_visibility.where(
            visible_by_user(user).or(arel_table[:public].eq(true)
                                       .or(arel_table[:author_id].eq(user.person_id)))
          ).select("DISTINCT #{table_name}.*")
        end

        def self.from_person_visible_by_user(user, person)
          return owned_by_user(user) if person == user.person

          with_visibility.where(author_id: person.id).where(
            visible_by_user(user).or(arel_table[:public].eq(true))
          ).select("DISTINCT #{table_name}.*")
        end

        def self.for_visible_shareable_sql(max_time, order, limit=15, types=Stream::Base::TYPES_OF_POST_IN_STREAM)
          by_max_time(max_time, order).order(table_name + ".id DESC").where(type: types).limit(limit)
        end

        def self.by_max_time(max_time, order="created_at")
          where("#{table_name}.#{order} < ?", max_time).order("#{table_name}.#{order} DESC")
        end

        def self.owned_by_user(user)
          user.person.send(table_name).where(pending: false)
        end

        def self.visible_by_user(user)
          ShareVisibility.arel_table[:user_id].eq(user.id)
            .and(ShareVisibility.arel_table[:shareable_type].eq(base_class.to_s))
        end
        private_class_method :visible_by_user
      end
    end

    # @return [Integer]
    def update_reshares_counter
      self.class.where(id: id).update_all(reshares_count: reshares.count)
    end
  end
end
