##
# RFC 4422:
# http://tools.ietf.org/html/rfc4422
module SASL
  ##
  # You must derive from class Preferences and overwrite methods you
  # want to implement.
  class Preferences
    attr_reader :config
    # key in config hash
    # authzid: Authorization identitiy ('username@domain' in XMPP)
    # realm: Realm ('domain' in XMPP)
    # digest-uri: : serv-type/serv-name | serv-type/host/serv-name ('xmpp/domain' in XMPP)
    # username
    # has_password?
    # allow_plaintext?
    # password
    # want_anonymous?
    
    def initialize (config)
      @config = {:has_password? => false, :allow_plaintext? => false, :want_anonymous? => false}.merge(config.dup)
    end
    def method_missing(sym, *args, &block)
      @config.send "[]", sym, &block
    end    
  end

  ##
  # Will be raised by SASL.new_mechanism if mechanism passed to the
  # constructor is not known.
  class UnknownMechanism < RuntimeError
    def initialize(mechanism)
      @mechanism = mechanism
    end

    def to_s
      "Unknown mechanism: #{@mechanism.inspect}"
    end
  end

  def SASL.new(mechanisms, preferences)
    best_mechanism = if preferences.want_anonymous? && mechanisms.include?('ANONYMOUS')
                       'ANONYMOUS'
                     elsif preferences.has_password?
                       if mechanisms.include?('DIGEST-MD5')
                         'DIGEST-MD5'
                       elsif preferences.allow_plaintext?
                         'PLAIN'
                       else
                         raise UnknownMechanism.new(mechanisms)
                       end
                     else
                       raise UnknownMechanism.new(mechanisms)
                     end
    new_mechanism(best_mechanism, preferences)
  end

  ##
  # Create a SASL Mechanism for the named mechanism
  #
  # mechanism:: [String] mechanism name
  def SASL.new_mechanism(mechanism, preferences)
    mechanism_class = case mechanism
                      when 'DIGEST-MD5'
                        DigestMD5
                      when 'PLAIN'
                        Plain
                      when 'ANONYMOUS'
                        Anonymous
                      else
                        raise UnknownMechanism.new(mechanism)
                      end
    mechanism_class.new(mechanism, preferences)
  end


  class AbstractMethod < Exception # :nodoc:
    def to_s
      "Abstract method is not implemented"
    end
  end

  ##
  # Common functions for mechanisms
  #
  # Mechanisms implement handling of methods start and receive. They
  # return: [message_name, content] or nil where message_name is
  # either 'auth' or 'response' and content is either a string which
  # may transmitted encoded as Base64 or nil.
  class Mechanism
    attr_reader :mechanism
    attr_reader :preferences

    def initialize(mechanism, preferences)
      @mechanism = mechanism
      @preferences = preferences
      @state = nil
    end

    def success?
      @state == :success
    end
    def failure?
      @state == :failure
    end

    def start
      raise AbstractMethod
    end


    def receive(message_name, content)
      case message_name
      when 'success'
        @state = :success
      when 'failure'
        @state = :failure
      end
      nil
    end
  end
end
