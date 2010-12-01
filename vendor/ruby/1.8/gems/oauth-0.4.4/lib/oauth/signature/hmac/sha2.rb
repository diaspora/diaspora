require 'oauth/signature/hmac/base'

module OAuth::Signature::HMAC
  class SHA2 < Base
    implements 'hmac-sha2'
    digest_klass 'SHA2'
  end
end
