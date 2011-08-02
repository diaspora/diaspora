module Fog
  class HMAC

    def initialize(type, key)
      @key = key
      case type
      when 'sha1'
        setup_sha1
      when 'sha256'
        setup_sha256
      end
    end

    def sign(data)
      @signer.call(data)
    end

    private

    def setup_sha1
      @digest = OpenSSL::Digest::Digest.new('sha1')
      @signer = lambda do |data|
        OpenSSL::HMAC.digest(@digest, @key, data)
      end
    end

    def setup_sha256
      begin
        @digest = OpenSSL::Digest::Digest.new('sha256')
        @signer = lambda do |data|
          OpenSSL::HMAC.digest(@digest, @key, data)
        end
      rescue RuntimeError => error
        unless error.message == 'Unsupported digest algorithm (sha256).'
          raise error
        else
          require 'hmac-sha2'
          @hmac = ::HMAC::SHA256.new(@key)
          @signer = lambda do |data|
            @hmac.update(data)
            @hmac.digest
          end
        end
      end
    end

  end
end