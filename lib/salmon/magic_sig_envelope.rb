#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
  class MagicSigEnvelope

    attr_accessor :data, :data_type, :encoding, :alg, :sig, :author

    # @return [MagicSigEnvelope]
    def self.parse(doc)
      env = self.new
      ns = {'me'=>'http://salmon-protocol.org/ns/magic-env'}
      env.encoding = doc.search('//me:env/me:encoding', ns).text.strip

      if env.encoding != 'base64url'
        raise ArgumentError, "Magic Signature data must be encoded with base64url, was #{env.encoding}"
      end

      env.data =  doc.search('//me:env/me:data', ns).text
      env.alg = doc.search('//me:env/me:alg', ns).text.strip

      unless 'RSA-SHA256' == env.alg
        raise ArgumentError, "Magic Signature data must be signed with RSA-SHA256, was #{env.alg}"
      end

      env.sig =  doc.search('//me:env/me:sig', ns).text
      env.data_type = doc.search('//me:env/me:data', ns).first['type'].strip

      env
    end

    # @return [MagicSigEnvelope]
    def self.create(user, activity)
      env = MagicSigEnvelope.new
      env.author = user.person
      env.data = Base64.urlsafe_encode64(activity)
      env.data_type = env.get_data_type
      env.encoding  = env.get_encoding
      env.alg = env.get_alg

      #TODO: WHY DO WE DOUBLE ENCODE
      env.sig = Base64.urlsafe_encode64(
        user.encryption_key.sign OpenSSL::Digest::SHA256.new, env.signable_string )

      env
    end

    # @return [String]
    def signable_string
      [@data, Base64.urlsafe_encode64(@data_type),Base64.urlsafe_encode64(@encoding),  Base64.urlsafe_encode64(@alg)].join(".")
    end

    # @return [String]
    def to_xml
      <<ENTRY
<me:env>
  <me:data type='#{@data_type}'>#{@data}</me:data>
  <me:encoding>#{@encoding}</me:encoding>
  <me:alg>#{@alg}</me:alg>
  <me:sig>#{@sig}</me:sig>
  </me:env>
ENTRY
    end

    # @return [String]
    def get_encoding
      'base64url'
    end

    # @return [String]
    def get_data_type
      'application/xml'
    end

    # @return [String]
    def get_alg
      'RSA-SHA256'
    end
  end
end
