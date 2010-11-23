#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Add URL safe Base64 support
module Base64
  module_function
  # Returns the Base64-encoded version of +bin+.
  # This method complies with RFC 4648.
  # No line feeds are added.
  def strict_encode64(bin)
    [bin].pack("m0")
  end

  # Returns the Base64-decoded version of +str+.
  # This method complies with RFC 4648.
  # ArgumentError is raised if +str+ is incorrectly padded or contains
  # non-alphabet characters.  Note that CR or LF are also rejected.
  def strict_decode64(str)
    str.unpack("m0").first
  end

  # Returns the Base64-encoded version of +bin+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_encode64(bin)
    strict_encode64(bin).tr("+/", "-_")
  end

  # Returns the Base64-decoded version of +str+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_decode64(str)
    strict_decode64(str.tr("-_", "+/"))
  end
end

# Verify documents secured with Magic Signatures
module Salmon

  class SalmonSlap
    attr_accessor :magic_sig, :author, :author_email, :aes_key, :iv, :parsed_data,
                  :data_type, :sig

    def self.create(user, activity)
      salmon = self.new
      salmon.author = user.person
      aes_key_hash = user.person.gen_aes_key
      salmon.aes_key = aes_key_hash['key']
      salmon.iv      = aes_key_hash['iv']
      salmon.magic_sig = MagicSigEnvelope.create(user , user.person.aes_encrypt(activity, aes_key_hash))
      salmon
    end

    def self.parse(xml, user)
      slap = self.new
      doc = Nokogiri::XML(xml)

      sig_doc = doc.search('entry')

      ### Header ##
      decrypted_header = user.decrypt(doc.search('encrypted_header').text)
      header_doc       = Nokogiri::XML(decrypted_header)
      slap.author_email= header_doc.search('uri').text.split("acct:").last
      slap.aes_key     = header_doc.search('aes_key').text
      slap.iv          = header_doc.search('iv').text

      slap.magic_sig = MagicSigEnvelope.parse sig_doc

      if  'base64url' == slap.magic_sig.encoding

        key_hash = {'key' => slap.aes_key, 'iv' => slap.iv}
        slap.parsed_data = user.aes_decrypt(decode64url(slap.magic_sig.data), key_hash)
        slap.sig = slap.magic_sig.sig
      else
        raise ArgumentError, "Magic Signature data must be encoded with base64url, was #{slap.magic_sig.encoding}"
      end

      slap.data_type = slap.magic_sig.data_type

      raise ArgumentError, "Magic Signature data must be signed with RSA-SHA256, was #{slap.magic_sig.alg}" unless 'RSA-SHA256' == slap.magic_sig.alg

      slap
    end

    def xml_for person
      xml =<<ENTRY
    <?xml version='1.0' encoding='UTF-8'?>
    <entry xmlns='http://www.w3.org/2005/Atom'>
    <encrypted_header>#{person.encrypt(decrypted_header)}</encrypted_header>
      #{@magic_sig.to_xml}
      </entry>
ENTRY

    end

    def decrypted_header
      header =<<HEADER
    <decrypted_header>
    <iv>#{iv}</iv>
    <aes_key>#{aes_key}</aes_key>
    <author>
      <name>#{@author.real_name}</name>
      <uri>acct:#{@author.diaspora_handle}</uri>
    </author>
    </decrypted_header>
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

  class MagicSigEnvelope
    attr_accessor :data, :data_type, :encoding, :alg, :sig, :author
    def self.parse(doc)
      env = self.new
      ns = {'me'=>'http://salmon-protocol.org/ns/magic-env'}
      env.encoding = doc.search('//me:env/me:encoding', ns).text.strip
      env.data =  doc.search('//me:env/me:data', ns).text
      env.alg = doc.search('//me:env/me:alg', ns).text.strip
      env.sig =  doc.search('//me:env/me:sig', ns).text
      env.data_type = doc.search('//me:env/me:data', ns).first['type'].strip
      env
    end

    def self.create(user, activity)
      env = MagicSigEnvelope.new
      env.author = user.person
      env.data = Base64.urlsafe_encode64(activity)
      env.data_type = env.get_data_type
      env.encoding  = env.get_encoding
      env.alg = env.get_alg

      env.sig = Base64.urlsafe_encode64(
        user.encryption_key.sign OpenSSL::Digest::SHA256.new, env.signable_string )

        env
    end

    def signable_string
      [@data, Base64.urlsafe_encode64(@data_type),Base64.urlsafe_encode64(@encoding),  Base64.urlsafe_encode64(@alg)].join(".")
    end

    def to_xml
      xml= <<ENTRY
<me:env xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <me:data type='#{@data_type}'>#{@data}</me:data>
  <me:encoding>#{@encoding}</me:encoding>
  <me:alg>#{@alg}</me:alg>
  <me:sig>#{@sig}</me:sig>
  </me:env>
ENTRY
      xml
    end

    def get_encoding
      'base64url'
    end

    def get_data_type
      'application/atom+xml'
    end

    def get_alg
      'RSA-SHA256'
    end

  end
end
