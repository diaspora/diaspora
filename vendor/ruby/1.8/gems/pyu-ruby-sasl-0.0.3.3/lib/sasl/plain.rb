module SASL
  ##
  # RFC 4616:
  # http://tools.ietf.org/html/rfc4616
  class Plain < Mechanism
    def start
      @state = nil
      message = [preferences.authzid.to_s,
                 preferences.username,
                 preferences.password].join("\000")
      ['auth', message]
    end
  end
end
