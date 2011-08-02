require 'typhoeus/hydra/callbacks'
require 'typhoeus/hydra/connect_options'
require 'typhoeus/hydra/stubbing'

module Typhoeus
  class Hydra
    include ConnectOptions
    include Stubbing
    extend Callbacks

    def initialize(options = {})
      @memoize_requests = true
      @multi       = Multi.new
      @easy_pool   = []
      initial_pool_size = options[:initial_pool_size] || 10
      @max_concurrency = options[:max_concurrency] || 200
      initial_pool_size.times { @easy_pool << Easy.new }
      @memoized_requests = {}
      @retrieved_from_cache = {}
      @queued_requests = []
      @running_requests = 0

      self.stubs = []
      @active_stubs = []
    end

    def self.hydra
      @hydra ||= new
    end

    def self.hydra=(val)
      @hydra = val
    end

    #
    # Abort the run on a best-effort basis.
    #
    # It won't abort the current burst of @max_concurrency requests,
    # however it won't fire the rest of the queued requests so the run
    # will be aborted as soon as possible...
    #
    def abort
      @queued_requests.clear
    end

    def clear_cache_callbacks
      @cache_setter = nil
      @cache_getter = nil
    end

    def fire_and_forget
      @queued_requests.each {|r| queue(r, false)}
      @multi.fire_and_forget
    end

    def queue(request, obey_concurrency_limit = true)
      return if assign_to_stub(request)

      # At this point, we are running over live HTTP. Make sure we haven't
      # disabled live requests.
      check_allow_net_connect!(request)

      if @running_requests >= @max_concurrency && obey_concurrency_limit
        @queued_requests << request
      else
        if request.method == :get
          if @memoize_requests && @memoized_requests.has_key?(request.url)
            if response = @retrieved_from_cache[request.url]
              request.response = response
              request.call_handlers
            else
              @memoized_requests[request.url] << request
            end
          else
            @memoized_requests[request.url] = [] if @memoize_requests
            get_from_cache_or_queue(request)
          end
        else
          get_from_cache_or_queue(request)
        end
      end
    end

    def run
      while !@active_stubs.empty?
        m = @active_stubs.first
        while request = m.requests.shift
          response = m.response
          response.request = request
          handle_request(request, response)
        end
        @active_stubs.delete(m)
      end

      @multi.perform
    ensure
      @multi.reset_easy_handles{|easy| release_easy_object(easy)}
      @memoized_requests = {}
      @retrieved_from_cache = {}
      @running_requests = 0
    end

    def disable_memoization
      @memoize_requests = false
    end

    def cache_getter(&block)
      @cache_getter = block
    end

    def cache_setter(&block)
      @cache_setter = block
    end

    def on_complete(&block)
      @on_complete = block
    end

    def on_complete=(proc)
      @on_complete = proc
    end

    def get_from_cache_or_queue(request)
      if @cache_getter
        val = @cache_getter.call(request)
        if val
          @retrieved_from_cache[request.url] = val
          handle_request(request, val, false)
        else
          @multi.add(get_easy_object(request))
        end
      else
        @multi.add(get_easy_object(request))
      end
    end
    private :get_from_cache_or_queue

    def get_easy_object(request)
      @running_requests += 1

      easy = @easy_pool.pop || Easy.new
      easy.verbose          = request.verbose
      if request.username || request.password
        auth = { :username => request.username, :password => request.password }
        auth[:method] = Typhoeus::Easy::AUTH_TYPES["CURLAUTH_#{request.auth_method.to_s.upcase}".to_sym] if request.auth_method
        easy.auth = auth
      end

      if request.proxy
        proxy = { :server => request.proxy }
        proxy[:type] = Typhoeus::Easy::PROXY_TYPES["CURLPROXY_#{request.proxy_type.to_s.upcase}".to_sym] if request.proxy_type
        easy.proxy = proxy if request.proxy
      end

      if request.proxy_username || request.proxy_password
        auth = { :username => request.proxy_username, :password => request.proxy_password }
        auth[:method] = Typhoeus::Easy::AUTH_TYPES["CURLAUTH_#{request.proxy_auth_method.to_s.upcase}".to_sym] if request.proxy_auth_method
        easy.proxy_auth = auth
      end

      easy.url          = request.url
      easy.method       = request.method
      easy.params       = request.params  if request.method == :post && !request.params.nil?
      easy.headers      = request.headers if request.headers
      easy.request_body = request.body    if request.body
      easy.timeout      = request.timeout if request.timeout
      easy.connect_timeout = request.connect_timeout if request.connect_timeout
      easy.follow_location = request.follow_location if request.follow_location
      easy.max_redirects = request.max_redirects if request.max_redirects
      easy.disable_ssl_peer_verification if request.disable_ssl_peer_verification
      easy.ssl_cert         = request.ssl_cert
      easy.ssl_cert_type    = request.ssl_cert_type
      easy.ssl_key          = request.ssl_key
      easy.ssl_key_type     = request.ssl_key_type
      easy.ssl_key_password = request.ssl_key_password
      easy.ssl_cacert       = request.ssl_cacert
      easy.ssl_capath       = request.ssl_capath
      easy.verbose          = request.verbose

      easy.on_success do |easy|
        queue_next
        handle_request(request, response_from_easy(easy, request))
        release_easy_object(easy)
      end
      easy.on_failure do |easy|
        queue_next
        handle_request(request, response_from_easy(easy, request))
        release_easy_object(easy)
      end
      easy.set_headers
      easy
    end
    private :get_easy_object

    def queue_next
      @running_requests -= 1
      queue(@queued_requests.pop) unless @queued_requests.empty?
    end
    private :queue_next

    def release_easy_object(easy)
      easy.reset
      @easy_pool.push easy
    end
    private :release_easy_object

    def handle_request(request, response, live_request = true)
      request.response = response

      self.class.run_global_hooks_for(:after_request_before_on_complete,
                                      request)

      if live_request && request.cache_timeout && @cache_setter
        @cache_setter.call(request)
      end
      @on_complete.call(response) if @on_complete

      request.call_handlers
      if requests = @memoized_requests[request.url]
        requests.each do |r|
          r.response = response
          r.call_handlers
        end
      end
    end
    private :handle_request

    def response_from_easy(easy, request)
      Response.new(:code                => easy.response_code,
                   :headers             => easy.response_header,
                   :body                => easy.response_body,
                   :time                => easy.total_time_taken,
                   :start_transfer_time => easy.start_transfer_time,
                   :app_connect_time    => easy.app_connect_time,
                   :pretransfer_time    => easy.pretransfer_time,
                   :connect_time        => easy.connect_time,
                   :name_lookup_time    => easy.name_lookup_time,
                   :effective_url       => easy.effective_url,
                   :curl_return_code => easy.curl_return_code,
                   :curl_error_message => easy.curl_error_message,
                   :request             => request)
    end
    private :response_from_easy
  end
end
