require 'digest/md5'

module SASL
  ##
  # RFC 2831:
  # http://tools.ietf.org/html/rfc2831
  class DigestMD5 < Mechanism
    attr_writer :cnonce

    def initialize(*a)
      super
      @nonce_count = 0
    end

    def start
      @state = nil
      unless defined? @nonce
        ['auth', nil]
      else
        # reauthentication
        receive('challenge', '')
      end
    end

    def receive(message_name, content)
      if message_name == 'challenge'
        c = decode_challenge(content)

        unless c['rspauth']
          response = {}
          if defined?(@nonce) && response['nonce'].nil?
            # Could be reauth
          else
            # No reauth:
            @nonce_count = 0
          end
          @nonce ||= c['nonce']
          response['nonce'] = @nonce
          response['charset'] = 'utf-8'
          response['username'] = preferences.username
          response['realm'] = c['realm'] || preferences.realm
          @cnonce = generate_nonce unless defined? @cnonce
          response['cnonce'] = @cnonce
          @nc = next_nc
          response['nc'] = @nc
          @qop = c['qop'] || 'auth'
          response['qop'] = 'auth' #@qop
          response['digest-uri'] = preferences.digest_uri
          response['response'] = response_value(response['nonce'], response['nc'], response['cnonce'], response['qop'], response['realm'])
          ['response', encode_response(response)]
        else
          rspauth_expected = response_value(@nonce, @nc, @cnonce, @qop, '')
          #p :rspauth_received=>c['rspauth'], :rspauth_expected=>rspauth_expected
          if c['rspauth'] == rspauth_expected
            ['response', nil]
          else
            # Bogus server?
            @state = :failure
            ['failure', nil]
          end
        end
      else
        # No challenge? Might be success or failure
        super
      end
    end

    private

    def decode_challenge(text)
      challenge = {}
      
      state = :key
      key = ''
      value = ''

      text.scan(/./) do |ch|
        if state == :key
          if ch == '='
            state = :value
          elsif ch =~ /\S/
            key += ch
          end
          
        elsif state == :value
          if ch == ','
            challenge[key] = value
            key = ''
            value = ''
            state = :key
          elsif ch == '"' and value == ''
            state = :quote
          else
            value += ch
          end

        elsif state == :quote
          if ch == '"'
            state = :value
          else
            value += ch
          end
        end
      end
      challenge[key] = value unless key == ''
      
      #p :decode_challenge => challenge
      challenge
    end

    def encode_response(response)
      #p :encode_response => response
      response.collect do |k,v|
        if ['username', 'cnonce', 'digest-uri', 'authzid','realm','qop'].include? k
          v.sub!('\\', '\\\\')
          v.sub!('"', '\\"')
          "#{k}=\"#{v}\""
        else
          "#{k}=#{v}"
        end
      end.join(',')
    end

    def generate_nonce
      nonce = ''
      while nonce.length < 32
        c = rand(128).chr
        nonce += c if c =~ /^[a-zA-Z0-9]$/
      end
      nonce
    end

    ##
    # Function from RFC2831
    def h(s); Digest::MD5.digest(s); end
    ##
    # Function from RFC2831
    def hh(s); Digest::MD5.hexdigest(s); end
    
    ##
    # Calculate the value for the response field
    def response_value(nonce, nc, cnonce, qop, realm, a2_prefix='AUTHENTICATE')
      #p :response_value => {:nonce=>nonce,
      #  :cnonce=>cnonce,
      #  :qop=>qop,
      #  :username=>preferences.username,
      #  :realm=>preferences.realm,
      #  :password=>preferences.password,
      #  :authzid=>preferences.authzid}
      a1_h = h("#{preferences.username}:#{realm}:#{preferences.password}")
      a1 = "#{a1_h}:#{nonce}:#{cnonce}"
      if preferences.authzid
        a1 += ":#{preferences.authzid}"
      end
      if qop && (qop.downcase == 'auth-int' || qop.downcase == 'auth-conf')
        a2 = "#{a2_prefix}:#{preferences.digest_uri}:00000000000000000000000000000000"
      else
        a2 = "#{a2_prefix}:#{preferences.digest_uri}"
      end
      hh("#{hh(a1)}:#{nonce}:#{nc}:#{cnonce}:#{qop}:#{hh(a2)}")
    end

    def next_nc
      @nonce_count += 1
      s = @nonce_count.to_s
      s = "0#{s}" while s.length < 8
      s
    end
  end
end

