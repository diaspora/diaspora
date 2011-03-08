#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Relayable

    def self.included(model)
      model.class_eval do
        #these fields must be in the schema for a relayable model
        xml_attr :parent_guid
        xml_attr :parent_author_signature
        xml_attr :author_signature
      end
    end
    
    def relayable
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
      end
    end

    def receive(user, person)
      object = self.class.where(:guid => self.guid).first || self

      unless object.parent.author == user.person || object.verify_parent_author_signature
        Rails.logger.info("event=receive status=abort reason='object signature not valid' recipient=#{user.diaspora_handle} sender=#{self.parent.author.diaspora_handle} payload_type=#{self.class} parent_id=#{self.parent.id}")
        return
      end

      #sign object as the parent creator if you've been hit UPSTREAM
      if user.owns? object.parent
        object.parent_author_signature = object.sign_with_key(user.encryption_key)
        object.save!
      end

      #dispatch object DOWNSTREAM, received it via UPSTREAM
      unless user.owns?(object)
        object.save!
        Postzord::Dispatch.new(user, object).post
      end

      object.socket_to_user(user, :aspect_ids => object.parent.aspect_ids) if object.respond_to? :socket_to_user
      if object.after_receive(user, person)
        object
      end
    end

    def after_receive(user, person)
      self
    end

    def signable_string
      raise NotImplementedException("Override this in your encryptable class")
    end

    def signature_valid?
      verify_signature(creator_signature, self.author)
    end

    def verify_signature(signature, person)
      if person.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_person guid=#{self.guid} model_id=#{self.id}")
        return false
      elsif person.public_key.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_key guid=#{self.guid} model_id=#{self.id}")
        return false
      elsif signature.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_signature guid=#{self.guid} model_id=#{self.id}")
        return false
      end
      log_string = "event=verify_signature status=complete model_id=#{id}"
      validity = person.public_key.verify "SHA", Base64.decode64(signature), signable_string
      log_string += " validity=#{validity}"
      Rails.logger.info(log_string)
      validity
    end

    def sign_with_key(key)
      sig = Base64.encode64(key.sign "SHA", signable_string)
      Rails.logger.info("event=sign_with_key status=complete model_id=#{id}")
      sig
    end

    def signable_accessors
      accessors = self.class.roxml_attrs.collect do |definition|
        definition.accessor
      end
      ['author_signature', 'parent_author_signature'].each do |acc|
        accessors.delete acc
      end
      accessors
    end

    def signable_string
      signable_accessors.collect{ |accessor|
        (self.send accessor.to_sym).to_s
      }.join(';')
    end

    def verify_parent_author_signature
      verify_signature(self.parent_author_signature, self.parent.author)
    end

    def signature_valid?
      verify_signature(self.author_signature, self.author)
    end


    def parent_class
      raise NotImplementedError.new('you must override parent_class in order to enable relayable on this model')
    end

    def parent
      raise NotImplementedError.new('you must override parent in order to enable relayable on this model')
    end

    def parent= parent
      raise NotImplementedError.new('you must override parent= in order to enable relayable on this model')
    end
  end
end
