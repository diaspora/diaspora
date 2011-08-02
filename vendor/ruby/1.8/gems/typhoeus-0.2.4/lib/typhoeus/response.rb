module Typhoeus
  class Response
    attr_accessor :request, :mock
    attr_reader :code, :headers, :body, :time,
                :requested_url, :requested_remote_method,
                :requested_http_method, :start_time,
                :effective_url, :start_transfer_time,
                :app_connect_time, :pretransfer_time,
                :connect_time, :name_lookup_time,
                :curl_return_code, :curl_error_message

    attr_writer :headers_hash

    def initialize(params = {})
      @code                  = params[:code]
      @curl_return_code      = params[:curl_return_code]
      @curl_error_message    = params[:curl_error_message]
      @status_message        = params[:status_message]
      @http_version          = params[:http_version]
      @headers               = params[:headers] || ''
      @body                  = params[:body]
      @time                  = params[:time]
      @requested_url         = params[:requested_url]
      @requested_http_method = params[:requested_http_method]
      @start_time            = params[:start_time]
      @start_transfer_time   = params[:start_transfer_time]
      @app_connect_time      = params[:app_connect_time]
      @pretransfer_time      = params[:pretransfer_time]
      @connect_time          = params[:connect_time]
      @name_lookup_time      = params[:name_lookup_time]
      @request               = params[:request]
      @effective_url         = params[:effective_url]
      @mock                  = params[:mock] || false  # default
      @headers_hash          = NormalizedHeaderHash.new(params[:headers_hash]) if params[:headers_hash]
    end

    # Returns true if this is a mock response.
    def mock?
      @mock
    end

    def headers_hash
      @headers_hash ||= begin
        headers.split("\n").map {|o| o.strip}.inject(Typhoeus::NormalizedHeaderHash.new) do |hash, o|
          if o.empty? || o =~ /^HTTP\/[\d\.]+/
            hash
          else
            i = o.index(":") || o.size
            key = o.slice(0, i)
            value = o.slice(i + 1, o.size)
            value = value.strip unless value.nil?
            if hash.has_key? key
              hash[key] = [hash[key], value].flatten
            else
              hash[key] = value
            end

            hash
          end
        end
      end
    end

    def status_message
      # http://rubular.com/r/eAr1oVYsVa
      @status_message ||= first_header_line ? first_header_line[/\d{3} (.*)$/, 1].chomp : nil
    end

    def http_version
      @http_version ||= first_header_line ? first_header_line[/HTTP\/(\S+)/, 1] : nil
    end

    def success?
      @code >= 200 && @code < 300
    end

    def modified?
      @code != 304
    end

    def timed_out?
      curl_return_code == 28
    end

    private

      def first_header_line
        @first_header_line ||= headers.split("\n").first
      end
  end
end
