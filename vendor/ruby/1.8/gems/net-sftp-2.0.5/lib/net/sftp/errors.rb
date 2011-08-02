module Net; module SFTP

  # The base exception class for the SFTP system.
  class Exception < RuntimeError; end

  # A exception class for reporting a non-success result of an operation.
  class StatusException < Net::SFTP::Exception

    # The response object that caused the exception.
    attr_reader :response

    # The error code (numeric)
    attr_reader :code

    # The description of the error
    attr_reader :description

    # Any incident-specific text given when the exception was raised
    attr_reader :text

    # Create a new status exception that reports the given code and
    # description.
    def initialize(response, text=nil)
      @response, @text = response, text
      @code = response.code
      @description = response.message
      @description = Response::MAP[@code] if @description.nil? || @description.empty?
    end

    # Override the default message format, to include the code and
    # description.
    def message
      m = super.dup
      m << " #{text}" if text
      m << " (#{code}, #{description.inspect})"
    end

  end
end; end
