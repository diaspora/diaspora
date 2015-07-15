module OpenidConnect
  class IdTokenConfig
    @@key = OpenSSL::PKey::RSA.new(2048)
    def self.public_key
      @@key.public_key
    end
    def self.private_key
      @@key
    end
  end
end
