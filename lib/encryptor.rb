#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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
