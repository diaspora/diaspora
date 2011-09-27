#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
 class Slap
    attr_accessor :magic_sig, :author, :author_id, :parsed_data
    attr_accessor :aes_key, :iv

    delegate :sig, :data_type, :to => :magic_sig

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

      salmon.magic_sig = MagicSigEnvelope.create(user, self.payload(activity, user, aes_key_hash))
      salmon
    end

    def self.from_xml(xml, receiving_user=nil)
      slap = self.new
      doc = Nokogiri::XML(xml)

      root_doc = doc.search('diaspora')

      ### Header ##
      header_doc       = slap.salmon_header(doc, receiving_user) 
      slap.process_header(header_doc)

      ### Envelope ##
      slap.magic_sig = MagicSigEnvelope.parse(root_doc)

      slap.parsed_data = slap.parse_data(receiving_user)

      slap
    end

    # @return [String]
    def self.payload(activity, user=nil, aes_key_hash=nil)
      activity
    end

    # Takes in a doc of the header and sets the author id
    # returns an empty hash
    # @return [String] Author id  
    def process_header(doc)
      self.author_id   = doc.search('author_id').text
    end

    # @return [String]
    def parse_data(user=nil)
      Slap.decode64url(self.magic_sig.data)
    end

    # @return [Nokogiri::Doc]
    def salmon_header(doc, user=nil)
      doc.search('header')
    end

    # @return [String] The constructed salmon, given a person
    # note this memoizes the xml, as for every user for unsigned salmon will be the same
    def xml_for(person)
      @xml =<<ENTRY
    <?xml version='1.0' encoding='UTF-8'?>
    <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
      #{header(person)}
      #{@magic_sig.to_xml}
    </diaspora>
ENTRY
    end

    # Wraps plaintext header in <header></header> tags
    # @return [String] Header XML
    def header(person)
      "<header>#{plaintext_header}</header>"
    end

    # Generate a plaintext salmon header (unencrypted), sans <header></header> tags
    # @return [String] Header XML (sans <header></header> tags)
    def plaintext_header
      header =<<HEADER
    <author_id>#{@author.diaspora_handle}</author_id>
HEADER
    end

    # @return [Person] Author of the salmon object
    def author
      if @author.nil?
        @author ||= Person.by_account_identifier @author_id
        raise "did you remember to async webfinger?" if @author.nil?
      end
      @author
    end

    # Decode URL-safe-Base64. This implements
    def self.decode64url(str)
      # remove whitespace
      sans_whitespace = str.gsub(/\s/, '')
      # pad to a multiple of 4
      string = sans_whitespace + '=' * ((4 - sans_whitespace.size) % 4)
      # convert to standard Base64
      # string = padded.tr('-','+').tr('_','/')

      # Base64.decode64(string)
      Base64.urlsafe_decode64 string
    end

    # Check whether this envelope's signature can be verified with the
    # provided OpenSSL::PKey::RSA public_key.
    # Example:
    #
    #   env.verified_for_key? OpenSSL::PKey::RSA.new(File.open('public_key.pem'))
    #   # -> true
    def verified_for_key?(public_key)
      signature = Base64.urlsafe_decode64(self.magic_sig.sig)
      signed_data = self.magic_sig.signable_string# Base64.urlsafe_decode64(self.magic_sig.signable_string)

      public_key.verify(OpenSSL::Digest::SHA256.new, signature, signed_data )
    end

    # Decode a string containing URL safe Base64 into an integer
    # Example:
    #
    #   MagicSig.b64_to_n('AQAB')
    #   # -> 645537
    def self.b64_to_n(str)
      packed = decode64url(str)
      packed.unpack('B*')[0].to_i(2)
    end

    # Parse a string containing a magic-public-key into an OpenSSL::PKey::RSA key.
    # Example:
    #
    #   key = MagicSig.parse_key('RSA.mVgY8RN6URBTstndvmUUPb4UZTdwvwmddSKE5z_jvKUEK6yk1u3rrC9yN8k6FilGj9K0eeUPe2hf4Pj-5CmHww.AQAB')
    #   key.n
    #   # -> 8031283789075196565022891546563591368344944062154100509645398892293433370859891943306439907454883747534493461257620351548796452092307094036643522661681091
    #   key.e
    #   # -> 65537
    def self.parse_key(str)
      n,e = str.match(/^RSA.([^.]*).([^.]*)$/)[1..2]
      build_key(b64_to_n(n),b64_to_n(e))
    end

    # Take two integers e, n and create a new OpenSSL::PKey::RSA key with them
    # Example:
    #
    #   n = 9487834027867356975347184933768917275269369900665861930617802608089634337052392076689226301419587057117740995382286148368168197915234368486155306558161867
    #   e = 65537
    #   key = MagicSig.build_key(n,e)
    #   key.public_encrypt(...) # for sending to strangers
    #   key.public_decrypt(...) # very rarely used
    #   key.verify(...) # for verifying signatures
    def self.build_key(n,e)
      key = OpenSSL::PKey::RSA.new
      key.n = n
      key.e = e
      key
    end
  end
end
