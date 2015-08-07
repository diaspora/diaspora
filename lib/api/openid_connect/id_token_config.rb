module Api
  module OpenidConnect
    class IdTokenConfig
      private_key = OpenSSL::PKey::RSA.new(2048)
      key_file_path = File.join(Rails.root, "config", "oidc_key.pem")
      if File.exist?(key_file_path)
        private_key = OpenSSL::PKey::RSA.new(File.read(key_file_path))
      else
        open key_file_path, "w" do |io|
          io.write private_key.to_pem
        end
        File.chmod(0600, key_file_path)
      end
      PRIVATE_KEY = private_key
      PUBLIC_KEY = private_key.public_key
    end
  end
end
