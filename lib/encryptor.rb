#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



module Encryptor
  module Public
    def encrypt cleartext
      aes_key = gen_aes_key
      ciphertext = aes_encrypt(cleartext, aes_key)
      encrypted_key = encrypt_aes_key aes_key
      cipher_hash = {:aes_key => encrypted_key, :ciphertext => ciphertext}
      Base64.encode64( cipher_hash.to_json ) 
    end

    def gen_aes_key
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      key = cipher.random_key
      iv = cipher.random_iv
      {'key' => Base64.encode64(key), 'iv' => Base64.encode64(iv)}
    end

    def aes_encrypt(txt, key)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.encrypt
      cipher.key = Base64.decode64 key['key']
      cipher.iv  = Base64.decode64 key['iv']
      ciphertext = ''
      ciphertext << cipher.update(txt)
      ciphertext << cipher.final
      Base64.encode64 ciphertext
    end

    def encrypt_aes_key key
      Base64.encode64 encryption_key.public_encrypt( key.to_json )
    end
  end

  module Private
    def decrypt cipher_json
      json = JSON.parse(Base64.decode64 cipher_json)
      aes_key = get_aes_key json['aes_key']
      aes_decrypt(json['ciphertext'], aes_key)
    end

    def get_aes_key encrypted_key
      clear_key = encryption_key.private_decrypt( Base64.decode64 encrypted_key )
      JSON::parse(clear_key)
    end

    def aes_decrypt(ciphertext, key)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.key = Base64.decode64 key['key']
      cipher.iv  = Base64.decode64 key['iv']
      txt = ''
      txt << cipher.update(Base64.decode64 ciphertext)
      txt << cipher.final
      txt
    end


  end
end
