require 'hmac'
require 'digest/rmd160'

module HMAC
  class RMD160 < Base
    def initialize(key = nil)
      super(Digest::RMD160, 64, 20, key)
    end
    public_class_method :new, :digest, :hexdigest
  end
end
