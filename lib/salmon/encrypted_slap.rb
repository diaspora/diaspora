#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
  class EncryptedSlap < Slap

    # Construct an encrypted header
    # @return [String] Header XML
    def header(person)
      <<XML
        <encrypted_header>
          #{person.encrypt(plaintext_header)}
        </encrypted_header>
XML
    end

    def plaintext_header
      header =<<HEADER
<decrypted_header>
    <iv>#{iv}</iv>
    <aes_key>#{aes_key}</aes_key>
    <author_id>#{@author.diaspora_handle}</author_id>
</decrypted_header>
HEADER
    end

    # @return [String, Boolean] False if RSAError; XML if no error
    def xml_for(person)
      begin
       super 
      rescue OpenSSL::PKey::RSAError => e
        Rails.logger.info("event => :invalid_rsa_key, :identifier => #{person.diaspora_handle}")
        false
      end
    end
    
    # Takes in a doc of the header and sets the author id
    # returns an empty hash
    # @return [Hash]
    def process_header(doc)
      self.author_id   = doc.search('author_id').text
      self.aes_key     = doc.search('aes_key').text
      self.iv          = doc.search('iv').text
    end
    
    # Decrypts an encrypted magic sig envelope
    # @param key_hash [Hash] Contains 'key' (aes) and 'iv' values
    # @param user [User]
    def parse_data(user)
      user.aes_decrypt(super, {'key' => self.aes_key, 'iv' => self.iv})
    end

    # Decrypts and parses out the salmon header
    # @return [Nokogiri::Doc]
    def salmon_header(doc, user)
      header = user.decrypt(doc.search('encrypted_header').text)
      Nokogiri::XML(header)
    end

    # Encrypt the magic sig
    # @return [String]
    def self.payload(activity, user, aes_key_hash)
      user.person.aes_encrypt(activity, aes_key_hash)
    end
  end
end
