require 'hmac'
require 'digest/md5'

module HMAC
  class MD5 < Base
    def initialize(key = nil)
      super(Digest::MD5, 64, 16, key)
    end
    public_class_method :new, :digest, :hexdigest
  end
end
