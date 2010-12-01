# -*- encoding: utf-8 -*-

require 'oauth/signature/base'
require 'digest/hmac'

module OAuth::Signature::HMAC
  class Base < OAuth::Signature::Base

  private
    def digest
      self.class.digest_class Object.module_eval("::Digest::#{self.class.digest_klass}")
      Digest::HMAC.digest(signature_base_string, secret, self.class.digest_class)
    end
  end
end
