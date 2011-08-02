require 'oauth/signature/base'
require 'digest/sha1'

module OAuth::Signature
  class SHA1 < Base
    implements 'sha1'
    digest_class Digest::SHA1

    def signature_base_string
      secret + super
    end
  end
end
