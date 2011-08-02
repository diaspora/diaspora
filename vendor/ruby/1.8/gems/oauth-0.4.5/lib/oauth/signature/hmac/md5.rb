require 'oauth/signature/hmac/base'

module OAuth::Signature::HMAC
  class MD5 < Base
    implements 'hmac-md5'
    digest_class 'MD5'
  end
end
