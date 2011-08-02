module Typhoeus
  class RemoteProxyObject
    instance_methods.each { |m| undef_method m unless m =~ /^__|object_id/ }

    def initialize(clear_memoized_store_proc, easy, options = {})
      @clear_memoized_store_proc = clear_memoized_store_proc
      @easy      = easy
      @success   = options[:on_success]
      @failure   = options[:on_failure]
      @cache     = options.delete(:cache)
      @cache_key = options.delete(:cache_key)
      @timeout   = options.delete(:cache_timeout)
      Typhoeus.add_easy_request(@easy)
    end

    def method_missing(sym, *args, &block)
      unless @proxied_object
        if @cache && @cache_key
          @proxied_object = @cache.get(@cache_key) rescue nil
        end

        unless @proxied_object
          Typhoeus.perform_easy_requests
          response = Response.new(:code => @easy.response_code,
                                  :curl_return_code => @easy.curl_return_code,
                                  :curl_error_message => @easy.curl_error_message,
                                  :headers => @easy.response_header,
                                  :body => @easy.response_body,
                                  :time => @easy.total_time_taken,
                                  :requested_url => @easy.url,
                                  :requested_http_method => @easy.method,
                                  :start_time => @easy.start_time)
          if @easy.response_code >= 200 && @easy.response_code < 300
            Typhoeus.release_easy_object(@easy)
            @proxied_object = @success.nil? ? response : @success.call(response)

            if @cache && @cache_key
              @cache.set(@cache_key, @proxied_object, @timeout)
            end
          else
            @proxied_object = @failure.nil? ? response : @failure.call(response)
          end
         @clear_memoized_store_proc.call
       end
      end

      @proxied_object.__send__(sym, *args, &block)
    end
  end
end
