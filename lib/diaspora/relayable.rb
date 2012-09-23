#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Relayable
    include Encryptable

    def self.included(model)
      model.class_eval do
        #these fields must be in the schema for a relayable model
        xml_attr :parent_guid
        xml_attr :parent_author_signature
        xml_attr :author_signature

        validates_associated :parent
        validates :author, :presence => true
        validate :author_is_not_ignored

        delegate :public?, to: :parent
        delegate :author, :diaspora_handle, to: :parent, prefix: true

        after_create do
          parent.touch(:interacted_at) if parent.respond_to?(:interacted_at)
        end

      end
    end

    def author_is_not_ignored
      if self.new_record? && self.parent.present?
        post_author = self.parent.author
        relayable_author = self.author

        if post_author.local? && post_author.owner.ignored_people.include?(relayable_author)
          self.errors.add(:author_id, 'This person is ignored by the post author')
          #post_author.owner.retract(self)
        end
      end
    end

    # @return [Boolean] true
    def relayable?
      true
    end

    # @return [String]
    def parent_guid
      return nil unless parent.present?
      self.parent.guid
    end

    def parent_guid= new_parent_guid
      self.parent = parent_class.where(:guid => new_parent_guid).first
    end

    # @return [Array<Person>]
    def subscribers(user)
      if user.owns?(self.parent)
        self.parent.subscribers(user)
      elsif user.owns?(self)
        [self.parent.author]
      else
        []
      end
    end

    def receive(user, person=nil)
      comment_or_like = self.class.where(:guid => self.guid).first || self

      # Check to make sure the signature of the comment or like comes from the person claiming to author it
      unless comment_or_like.parent_author == user.person || comment_or_like.verify_parent_author_signature
        Rails.logger.info("event=receive status=abort reason='object signature not valid' recipient=#{user.diaspora_handle} sender=#{self.parent.author.diaspora_handle} payload_type=#{self.class} parent_id=#{self.parent.id}")
        return
      end

      # As the owner of the post being liked or commented on, you need to add your own signature in order to
      # pass it to the people who received your original post
      if user.owns? comment_or_like.parent
        comment_or_like.parent_author_signature = comment_or_like.sign_with_key(user.encryption_key)
        comment_or_like.save!
      end

      # Dispatch object DOWNSTREAM, received it via UPSTREAM
      unless user.owns?(comment_or_like)
        comment_or_like.save!
        Postzord::Dispatcher.build(user, comment_or_like).post
      end

      if comment_or_like.after_receive(user, person)
        comment_or_like
      end
    end

    # @return [Object]
    def after_receive(user, person)
      self
    end

    def initialize_signatures
      #sign relayable as model creator
      self.author_signature = self.sign_with_key(author.owner.encryption_key)

      if !self.parent.blank? && self.author.owns?(self.parent)
        #sign relayable as parent object owner
        self.parent_author_signature = sign_with_key(author.owner.encryption_key)
      end
    end

    # @return [Boolean]
    def verify_parent_author_signature
      verify_signature(self.parent_author_signature, self.parent.author)
    end

    # @return [Boolean]
    def signature_valid?
      verify_signature(self.author_signature, self.author)
    end

    # @abstract
    # @return [Class]
    def parent_class
      raise NotImplementedError.new('you must override parent_class in order to enable relayable on this model')
    end

    # @abstract
    # @return An instance of Relayable#parent_class
    def parent
      raise NotImplementedError.new('you must override parent in order to enable relayable on this model')
    end

    # @abstract
    # @param parent An instance of Relayable#parent_class
    def parent= parent
      raise NotImplementedError.new('you must override parent= in order to enable relayable on this model')
    end
  end
end
