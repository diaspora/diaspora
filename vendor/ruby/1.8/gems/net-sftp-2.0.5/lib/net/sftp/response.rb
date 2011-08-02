require 'net/sftp/constants'

module Net; module SFTP

  # Encapsulates a response from the remote server, to a specific client
  # request. Response objects are passed as parameters to callbacks when you
  # are performing asynchronous operations; when you call Net::SFTP::Request#wait,
  # you can get the corresponding response object via Net::SFTP::Request#response.
  #
  #   sftp.open("/path/to/file") do |response|
  #     p response.ok?
  #     p response[:handle]
  #   end
  #
  #   sftp.loop
  class Response
    include Net::SFTP::Constants::StatusCodes

    # The request object that this object is in response to
    attr_reader :request

    # A hash of request-specific data, such as a file handle or attribute information
    attr_reader :data

    # The numeric code, one of the FX_* constants
    attr_reader :code

    # The textual message for this response (possibly blank)
    attr_reader :message

    # Create a new Response object for the given Net::SFTP::Request instance,
    # and with the given data. If there is no :code key in the data, the
    # code is assumed to be FX_OK.
    def initialize(request, data={}) #:nodoc:
      @request, @data = request, data
      @code, @message = data[:code] || FX_OK, data[:message]
    end

    # Retrieve the data item with the given +key+. The key is converted to a
    # symbol before being used to lookup the value.
    def [](key)
      data[key.to_sym]
    end

    # Returns a textual description of this response, including the status
    # code and name.
    def to_s
      if message && !message.empty? && message.downcase != MAP[code]
        "#{message} (#{MAP[code]}, #{code})"
      else
        "#{MAP[code]} (#{code})"
      end
    end

    alias :to_str :to_s

    # Returns +true+ if the status code is FX_OK; +false+ otherwise.
    def ok?
      code == FX_OK
    end

    # Returns +true+ if the status code is FX_EOF; +false+ otherwise.
    def eof?
      code == FX_EOF
    end

    #--
    MAP = constants.inject({}) do |memo, name|
      next memo unless name =~ /^FX_(.*)/
      memo[const_get(name)] = $1.downcase.tr("_", " ")
      memo
    end
    #++
  end

end; end