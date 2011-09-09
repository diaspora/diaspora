#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
  class EncryptedSalmonSlap < SalmonSlap
    def header(person)
      <<XML
        <encrypted_header>
          #{person.encrypt("<decrypted_header>#{plaintext_header}</decrypted_header>")}
        </encrypted_header>
XML
    end

    def parse_data(key_hash, user)
      user.aes_decrypt(super, key_hash)
    end

    # @return [Nokogiri::Doc]
    def salmon_header(doc, user)
      header = user.decrypt(doc.search('encrypted_header').text)
      Nokogiri::XML(header)
    end
  end
end
