#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Shareable
    include Diaspora::Webhooks

    def self.included(model)
      model.instance_eval do
        include ROXML
        include Diaspora::Guid

        has_many :aspect_visibilities, :as => :shareable
        has_many :aspects, :through => :aspect_visibilities

        has_many :share_visibilities, :as => :shareable
        has_many :contacts, :through => :share_visibilities

        belongs_to :author, :class_name => 'Person'

        validates :guid, :uniqueness => true

        #scopes
        scope :all_public, where(:public => true, :pending => false)

        def self.owned_or_visible_by_user(user)
          self.joins("LEFT OUTER JOIN share_visibilities ON share_visibilities.shareable_id = posts.id AND share_visibilities.shareable_type = 'Post'").
               joins("LEFT OUTER JOIN contacts ON contacts.id = share_visibilities.contact_id").
               where(Contact.arel_table[:user_id].eq(user.id).or(
                 self.arel_table[:public].eq(true).or(
                   self.arel_table[:author_id].eq(user.person.id)
                   )
                 )
               ).
               select("DISTINCT #{self.table_name}.*")
        end

        def self.for_visible_shareable_sql(max_time, order, limit = 15, types = Stream::Base::TYPES_OF_POST_IN_STREAM)
          by_max_time(max_time, order).
          where(:type => types).
          limit(limit)
        end

        def self.by_max_time(max_time, order='created_at')
          where("#{self.table_name}.#{order} < ?", max_time).order("#{self.table_name}.#{order} desc")
        end

        xml_attr :diaspora_handle
        xml_attr :public
        xml_attr :created_at
      end
    end

    def diaspora_handle
      read_attribute(:diaspora_handle) || self.author.diaspora_handle
    end

    def diaspora_handle= nd
      self.author = Person.where(:diaspora_handle => nd).first
      write_attribute(:diaspora_handle, nd)
    end

    # @param [User] user The user that is receiving this shareable.
    # @param [Person] person The person who dispatched this shareable to the
    # @return [void]
    def receive(user, person)
      #exists locally, but you dont know about it
      #does not exsist locally, and you dont know about it
      #exists_locally?
      #you know about it, and it is mutable
      #you know about it, and it is not mutable
      self.class.transaction do
        local_shareable = persisted_shareable

        if local_shareable && verify_persisted_shareable(local_shareable)
          self.receive_persisted(user, person, local_shareable)

        elsif !local_shareable
          self.receive_non_persisted(user, person)

        else
          Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason='update not from shareable owner' existing_shareable=#{self.id}")
          false
        end
      end
    end

    # The list of people that should receive this Shareable.
    #
    # @param [User] user The context, or dispatching user.
    # @return [Array<Person>] The list of subscribers to this shareable
    def subscribers(user)
      if self.public?
        user.contact_people
      else
        user.people_in_aspects(user.aspects_with_shareable(self.class, self.id))
      end
    end

    # @return [Integer]
    def update_reshares_counter
      self.class.where(:id => self.id).
        update_all(:reshares_count => self.reshares.count)
    end

    protected

    # @return [Shareable,void]
    def persisted_shareable
      self.class.where(:guid => self.guid).first
    end

    # @return [Boolean]
    def verify_persisted_shareable(persisted_shareable)
      persisted_shareable.author_id == self.author_id
    end

    def receive_persisted(user, person, local_shareable)
      known_shareable = user.find_visible_shareable_by_id(self.class.base_class, self.guid, :key => :guid)
      if known_shareable
        if known_shareable.mutable?
          known_shareable.update_attributes(self.attributes)
          true
        else
          Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason=immutable") #existing_shareable=#{known_shareable.id}")
          false
        end
      else
        user.contact_for(person).receive_shareable(local_shareable)
        user.notify_if_mentioned(local_shareable)
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.diaspora_handle}") #existing_shareable=#{local_shareable.id}")
        true
      end
    end

    def receive_non_persisted(user, person)
      if self.save
        user.contact_for(person).receive_shareable(self)
        user.notify_if_mentioned(self)
        Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.diaspora_handle}")
        true
      else
        Rails.logger.info("event=receive payload_type=#{self.class} update=false status=abort sender=#{self.diaspora_handle} reason=#{self.errors.full_messages}")
        false
      end
    end

  end
end
