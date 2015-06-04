module Diaspora
  module Encryptable
    include Diaspora::Logging

    # Check that signature is a correct signature of #signable_string by person
    #
    # @param [String] signature The signature to be verified.
    # @param [Person] person The signer.
    # @return [Boolean]
    def verify_signature(signature, person)
      if person.nil?
        logger.warn "event=verify_signature status=abort reason=no_person guid=#{guid}"
        return false
      elsif person.public_key.nil?
        logger.warn "event=verify_signature status=abort reason=no_key guid=#{guid}"
        return false
      elsif signature.nil?
        logger.warn "event=verify_signature status=abort reason=no_signature guid=#{guid}"
        return false
      end
      validity = person.public_key.verify OpenSSL::Digest::SHA256.new, Base64.decode64(signature), signable_string
      logger.info "event=verify_signature status=complete guid=#{guid} validity=#{validity}"
      validity
    end

    # @param [OpenSSL::PKey::RSA] key An RSA key
    # @return [String] A Base64 encoded signature of #signable_string with key
    def sign_with_key(key)
      sig = Base64.strict_encode64(key.sign( OpenSSL::Digest::SHA256.new, signable_string ))
      logger.info "event=sign_with_key status=complete guid=#{guid}"
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
