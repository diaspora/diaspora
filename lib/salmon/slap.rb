#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Salmon
 class Slap
    attr_accessor :magic_sig, :author, :author_email, :parsed_data
    attr_accessor :aes_key, :iv

    delegate :sig, :data_type, :to => :magic_sig

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

      entry_doc = doc.search('entry')

      ### Header ##
      header_doc       = slap.salmon_header(doc, receiving_user) 
      slap.author_email= header_doc.search('uri').text.split("acct:").last

      slap.aes_key     = header_doc.search('aes_key').text
      slap.iv          = header_doc.search('iv').text

      slap.magic_sig = MagicSigEnvelope.parse(entry_doc)


      #should be in encrypted salmon only
      key_hash = {'key' => slap.aes_key, 'iv' => slap.iv}
      
      slap.parsed_data = slap.parse_data(key_hash, receiving_user)

      slap
    end


    # @return [String]
    def self.payload(activity, user=nil, aes_key_hash=nil)
      activity
    end

    # @return [String]
    def parse_data(key_hash, user=nil)
      Slap.decode64url(self.magic_sig.data)
    end

    # @return [Nokogiri::Doc]
    def salmon_header(doc, user=nil)
      doc.search('header')
    end

    def xml_for(person)
      xml =<<ENTRY
    <?xml version='1.0' encoding='UTF-8'?>
    <entry xmlns='http://www.w3.org/2005/Atom'>
      #{header(person)}
      #{@magic_sig.to_xml}
    </entry>
ENTRY
    end

    def header(person)
      "<header>#{plaintext_header}</header>"
    end

    def plaintext_header
      header =<<HEADER
    <iv>#{iv}</iv>
    <aes_key>#{aes_key}</aes_key>
    <author>
      <name>#{@author.name}</name>
      <uri>acct:#{@author.diaspora_handle}</uri>
    </author>
HEADER
    end

    def author
      if @author.nil?
        @author ||= Person.by_account_identifier @author_email
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
