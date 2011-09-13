#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
  class EncryptedSlap < Slap

    # Construct an encrypted header
    # @return [String] Header XML
    def header(person)
      <<XML
        <encrypted_header>
          #{person.encrypt("<decrypted_header>#{plaintext_header}</decrypted_header>")}
        </encrypted_header>
XML
    end

    # Decrypts an encrypted magic sig envelope
    # @param key_hash [Hash] Contains 'key' (aes) and 'iv' values
    # @param user [User]
    def parse_data(key_hash, user)
      user.aes_decrypt(super, key_hash)
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
