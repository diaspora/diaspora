require 'oauth/signature/base'
require 'digest/md5'

module OAuth::Signature
  class MD5 < Base
    implements 'md5'
    digest_class Digest::MD5

    def signature_base_string
      secret + super
    end
  end
end
