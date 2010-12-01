# =XMPP4R - XMPP Library for Ruby
# License:: Ruby's license (see the LICENSE file) or GNU GPL, at your option.
# Website::http://home.gna.org/xmpp4r/

begin
  require 'base64'
rescue LoadError
  ##
  # Ruby 1.9 has dropped the Base64 module,
  # this is a replacement
  #
  # We could replace all call by Array#pack('m')
  # and String#unpack('m'), but this module
  # improves readability.
  module Base64
    ##
    # Encode a String
    # data:: [String] Binary
    # result:: [String] Binary in Base64
    def self.encode64(data)
      [data].pack('m')
    end

    ##
    # Decode a Base64-encoded String
    # data64:: [String] Binary in Base64
    # result:: [String] Binary
    def self.decode64(data64)
      data64.unpack('m').first
    end
  end
end
