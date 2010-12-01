require 'oauth/signature/hmac/base'

module OAuth::Signature::HMAC
  class SHA1 < Base
    implements 'hmac-sha1'
    digest_klass 'SHA1'
    hash_class ::Digest::SHA1
  end
end
