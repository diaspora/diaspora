#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



  module Encryptable
   def signable_string
     raise NotImplementedException("Override this in your encryptable class")
   end

    def signature_valid?
     verify_signature(creator_signature, person) 
    end
    
    def verify_signature(signature, person)
      if person.nil?
        Rails.logger.info("Verifying sig on #{signable_string} but no person is here")
        return false
      elsif person.encryption_key.nil?
        Rails.logger.info("Verifying sig on #{signable_string} but #{person.real_name} has no key")
        return false
      elsif signature.nil?
        Rails.logger.info("Verifying sig on #{signable_string} but #{person.real_name} did not sign")
        return false
      end
      Rails.logger.debug("Verifying sig on #{signable_string} from person #{person.real_name}")
      validity = person.encryption_key.verify "SHA", Base64.decode64(signature), signable_string
      Rails.logger.debug("Validity: #{validity}")
      validity
    end
    
    def sign_with_key(key)
      Rails.logger.debug("Signing #{signable_string}")
      Base64.encode64(key.sign "SHA", signable_string)
    end

  end

