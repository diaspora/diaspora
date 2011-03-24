module Diaspora
  module Encryptable
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

    #def signable_string
    #  raise NotImplementedError.new("Implement this in your encryptable class")
    #end
  end
end
