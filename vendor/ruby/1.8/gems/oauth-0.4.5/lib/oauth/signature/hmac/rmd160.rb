require 'oauth/signature/hmac/base'

module OAuth::Signature::HMAC
  class RMD160 < Base
    implements 'hmac-rmd160'
    digest_klass 'RMD160'
  end
end
