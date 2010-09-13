#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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

