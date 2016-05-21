#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Relayable
    include Encryptable

    def self.included(model)
      model.class_eval do
        attr_writer :parent_author_signature

        #these fields must be in the schema for a relayable model
        xml_attr :parent_guid
        xml_attr :parent_author_signature
        xml_attr :author_signature

        validates_associated :parent
        validates :author, :presence => true
        validate :author_is_not_ignored

        delegate :public?, to: :parent
        delegate :author, :diaspora_handle, to: :parent, prefix: true

        after_commit :on => :create do
          parent.touch(:interacted_at) if parent.respond_to?(:interacted_at)
        end

      end
    end

    def author_is_not_ignored
      unless new_record? && parent.present? && parent.author.local? &&
        parent.author.owner.ignored_people.include?(author)
        return
      end

      errors.add(:author_id, "This relayable author is ignored by the post author")
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
      @parent_guid = new_parent_guid
      self.parent = parent_class.where(guid: new_parent_guid).first
    end

    # @return [Array<Person>]
    def subscribers
      if parent.author.local?
        parent.subscribers
      else
        [parent.author]
      end
    end

    def initialize_signatures
      #sign relayable as model creator
      self.author_signature = self.sign_with_key(author.owner.encryption_key)
    end

    def parent_author_signature
      unless parent.blank? || parent.author.owner.nil?
        @parent_author_signature = sign_with_key(parent.author.owner.encryption_key)
      end
      @parent_author_signature
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

    # ROXML hook ensuring our own hooks are called
    def after_parse
      if @parent_guid
        self.parent ||= fetch_parent(@parent_guid)
      end
    end

    # Childs should override this to support fetching a missing parent
    # @param guid the parents guid
    def fetch_parent guid
    end
  end
end
