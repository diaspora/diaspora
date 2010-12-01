module SASL
  ##
  # SASL ANONYMOUS where you only send a username that may not get
  # evaluated by the server.
  #
  # RFC 4505:
  # http://tools.ietf.org/html/rfc4505
  class Anonymous < Mechanism
    def start
      @state = nil
      ['auth', preferences.username.to_s]
    end
  end
end
