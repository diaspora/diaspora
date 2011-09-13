#   Copyright (c) 2010, Diaspora Inc.  This file is
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
      end
    end

    def relayable?
      true
    end

    def parent_guid
      self.parent.guid
    end

    def parent_guid= new_parent_guid
      self.parent = parent_class.where(:guid => new_parent_guid).first
    end

    def subscribers(user)
      if user.owns?(self.parent)
        self.parent.subscribers(user)
      elsif user.owns?(self)
        [self.parent.author]
      else
        raise "What are you doing with a relayable that you have nothing to do with?"
        #[] 
      end
    end

    def receive(user, person)

      self.class.transaction do
        comment_or_like = self.class.where(:guid => self.guid).first || self

        #check to make sure the signature of the comment or like comes from the person claiming to authoring said comment or like
        unless comment_or_like.parent.author == user.person || comment_or_like.verify_parent_author_signature
          Rails.logger.info("event=receive status=abort reason='object signature not valid' recipient=#{user.diaspora_handle} sender=#{self.parent.author.diaspora_handle} payload_type=#{self.class} parent_id=#{self.parent.id}")
          return
        end

        #as the owner of the post being liked or commented on, you need to add your own signature in order to pass it to the people who received your original post
        if user.owns? comment_or_like.parent
          comment_or_like.parent_author_signature = comment_or_like.sign_with_key(user.encryption_key)

          comment_or_like.save!
        end

        #dispatch object DOWNSTREAM, received it via UPSTREAM
        unless user.owns?(comment_or_like)
          puts "i am #{user.username}, I am reiveiving and object for #{person.owner.username}"
          pp self
          comment_or_like.save!
          Postzord::Dispatcher.new(user, comment_or_like).post
        end

        comment_or_like.socket_to_user(user) if comment_or_like.respond_to? :socket_to_user

        if comment_or_like.after_receive(user, person)
          comment_or_like 
        end
      end
    end

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
