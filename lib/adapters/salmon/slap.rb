#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Adapters
  module Salmon
    class Slap
      attr_accessor :magic_sig, :author, :author_id, :parsed_data
      attr_accessor :aes_key, :iv

      # @param user [User]
      # @param activity [String] A decoded string
      # @return [Slap]
      def self.create_by_user_and_activity(user, activity)
        salmon = self.new
        salmon.author   = user.person
        aes_key_hash    = user.person.gen_aes_key

        #additional headers
        salmon.aes_key  = aes_key_hash['key']
        salmon.iv       = aes_key_hash['iv']

        pkey = OpenSSL::PKey::RSA.new(user.serialized_private_key)
        require 'pry'; binding.pry
        salmon.magic_sig = DiasporaFederation::Salmon::MagicEnvelope.new(pkey, activity)
        salmon.magic_sig.envelop
        salmon
      end

      def self.from_xml(xml, receiving_user=nil)
        require 'pry'; binding.pry
        #pkey = OpenSSL::PKey::RSA.new(receiving_user.serialized_private_key)
        DiasporaFederation::Salmon::Slap.from_xml(xml)
      end
    end
  end
end
