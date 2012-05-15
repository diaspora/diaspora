module Diaspora
  module Encryptable
    # Check that signature is a correct signature of #signable_string by person
    #
    # @param [String] signature The signature to be verified.
    # @param [Person] person The signer.
    # @return [Boolean]
    def verify_signature(signature, person)
      if person.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_person guid=#{self.guid}")
        return false
      elsif person.public_key.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_key guid=#{self.guid}")
        return false
      elsif signature.nil?
        Rails.logger.info("event=verify_signature status=abort reason=no_signature guid=#{self.guid}")
        return false
      end
      log_string = "event=verify_signature status=complete guid=#{self.guid}"
      validity = person.public_key.verify OpenSSL::Digest::SHA256.new, Base64.decode64(signature), signable_string
      log_string += " validity=#{validity}"
      Rails.logger.info(log_string)
      validity
    end

    # @param [OpenSSL::PKey::RSA] key An RSA key
    # @return [String] A Base64 encoded signature of #signable_string with key
    def sign_with_key(key)
      sig = Base64.strict_encode64(key.sign( OpenSSL::Digest::SHA256.new, signable_string ))
      log_hash = {:event => :sign_with_key, :status => :complete}
      log_hash.merge(:model_id => self.id) if self.respond_to?(:persisted?)
      Rails.logger.info(log_hash)
      sig
    end

    # @return [Array<String>] The ROXML attrs other than author_signature and parent_author_signature.
    def signable_accessors
      accessors = self.class.roxml_attrs.collect do |definition|
        definition.accessor
      end
      ['author_signature', 'parent_author_signature'].each do |acc|
        accessors.delete acc
      end
      accessors
    end

    # @return [String] Defaults to the ROXML attrs which are not signatures.
    def signable_string
      signable_accessors.collect{ |accessor|
        (self.send accessor.to_sym).to_s
      }.join(';')
    end
  end
end
