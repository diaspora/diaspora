  module Encryptable
   def signable_string
     ""
   end
    def verify_creator_signature
      verify_signature(creator_signature, person)
    end
    
    def verify_signature(signature, person)
      return false unless signature && person.key_fingerprint
      validity = nil
      GPGME::verify(signature, signable_string, 
        {:armor => true, :always_trust => true}){ |sig|
        validity =  sig.status == GPGME::GPG_ERR_NO_ERROR &&
            sig.fpr == person.key_fingerprint
      }
      return validity
    end
    
    protected
    def sign_if_mine
      if self.person == User.owner
        self.creator_signature = sign
      end
    end

    def sign
      sign_with_key(User.owner.key)
    end

    def sign_with_key(key)
      GPGME::sign(signable_string,nil,
          {:armor=> true, :mode => GPGME::SIG_MODE_DETACH, :signers => [key]})
    end
  end

