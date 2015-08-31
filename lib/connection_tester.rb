
class ConnectionTester
  NODEINFO_SCHEMA   = "http://nodeinfo.diaspora.software/ns/schema/1.0"
  NODEINFO_FRAGMENT = "/.well-known/nodeinfo"

  class << self
    # Test the reachability of a server by the given HTTP/S URL.
    # In the first step, a DNS query is performed to check whether the
    # given name even resolves correctly.
    # The second step is to send a HTTP request and look at the returned
    # status code or any returned errors.
    # This function isn't intended to check for the availability of a
    # specific page, instead a GET request is sent to the root directory
    # of the server.
    # In the third step an attempt is made to determine the software version
    # used on the server, via the nodeinfo page.
    #
    # @api This is the entry point you're supposed to use for testing
    #   connections to other diaspora-compatible servers.
    # @param [String] server URL
    # @return [Result] result object containing information about the
    #   server and to what point the connection was successful
    def check(url)
      url = "http://#{url}" unless url.include?("://")
      result = Result.new

      begin
        ct = ConnectionTester.new(url, result)

        # test DNS resolving
        ct.resolve

        # test HTTP request
        ct.request

        # test for the diaspora* version
        ct.nodeinfo

      rescue Failure => e
        result_from_failure(result, e)
      end

      result.freeze
    end

    private

    # infer some attributes of the result object based on the failure
    def result_from_failure(result, error)
      result.error = error

      case error
      when AddressFailure, DNSFailure, NetFailure
        result.reachable = false
      when SSLFailure
        result.reachable = true
        result.ssl_status = false
      when HTTPFailure
        result.reachable = true
      when NodeInfoFailure
        result.software_version = ""
      end
    end
  end

  # @raise [AddressFailure] if the specified url is not http(s)
  def initialize(url, result=Result.new)
    @url ||= url
    @result ||= result
    @uri ||= URI.parse(@url)
    raise AddressFailure,
          "invalid protocol: '#{@uri.scheme.upcase}'" unless http_uri?(@uri)

    result.hostname = @uri.host
  rescue AddressFailure => e
    raise e
  rescue URI::InvalidURIError => e
    raise AddressFailure, e.message
  rescue StandardError => e
    raise Failure, e.inspect
  end

  # Perform the DNS query, the IP address will be stored in the result
  # @raise [DNSFailure] caused by a failure to resolve or a timeout
  def resolve
    with_dns_resolver do |dns|
      addr = dns.getaddress(@uri.host)
      @result.ip = addr.to_s
    end
  rescue Resolv::ResolvError, Resolv::ResolvTimeout => e
    raise DNSFailure, "'#{@uri.host}' - #{e.message}"
  rescue StandardError => e
    raise Failure, e.inspect
  end

  # Perform a HTTP GET request to determine the following information
  # * is the host reachable
  # * is port 80/443 open
  # * is the SSL certificate valid (only on HTTPS)
  # * does the server return a successful HTTP status code
  # * is there a reasonable amount of redirects (3 by default)
  # (can't do a HEAD request, since that's not a defined route in the app)
  #
  # @raise [NetFailure, SSLFailure, HTTPFailure] if any of the checks fail
  # @return [Integer] HTTP status code
  def request
    with_http_connection do |http|
      response = capture_response_time { http.get("/") }
      handle_http_response(response)
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    raise NetFailure, e.message
  rescue Faraday::SSLError => e
    raise SSLFailure, e.message
  rescue ArgumentError, FaradayMiddleware::RedirectLimitReached, Faraday::ClientError => e
    raise HTTPFailure, e.message
  rescue StandardError => e
    raise Failure, e.inspect
  end

  # Try to find out the version of the other servers software.
  # Assuming the server speaks nodeinfo
  #
  # @raise [NodeInfoFailure] if the document can't be fetched
  #   or the attempt to parse it failed
  def nodeinfo
    with_http_connection do |http|
      ni_resp = http.get(NODEINFO_FRAGMENT)
      nd_resp = http.get(find_nodeinfo_url(ni_resp.body))
      find_software_version(nd_resp.body)
    end
  rescue Faraday::ResourceNotFound, JSON::JSONError => e
    raise NodeInfoFailure, e.message[0..255]
  rescue StandardError => e
    raise Failure, e.inspect
  end

  private

  def with_http_connection
    @http ||= Faraday.new(@url) do |c|
      c.use Faraday::Response::RaiseError
      c.use FaradayMiddleware::FollowRedirects, limit: 3
      c.adapter(Faraday.default_adapter)
      c.headers[:user_agent] = "diaspora-connection-tester"
      c.options.timeout = 12
      c.options.open_timeout = 6
      # use the configured CA
      c.ssl.ca_file = Faraday.default_connection.ssl.ca_file
    end
    yield(@http) if block_given?
  end

  def with_dns_resolver
    dns = Resolv::DNS.new
    yield(dns) if block_given?
  ensure
    dns.close
  end

  def http_uri?(uri)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  def uses_ssl?
    @uses_ssl
  end

  # request root path, measure response time
  # measured time may be skewed, if there are redirects
  #
  # @return [Faraday::Response]
  def capture_response_time
    start     = Time.zone.now
    resp = yield if block_given?
    @result.rt = ((Time.zone.now - start) * 1000.0).to_i # milliseconds
    resp
  end

  def handle_http_response(response)
    @uses_ssl = (response.env.url.scheme == "https")
    @result.status_code = Integer(response.status)

    if response.success?
      @result.reachable  = true
      @result.ssl_status = @uses_ssl
    else
      raise HTTPFailure, "unsuccessful response code: #{response.status}"
    end
  end

  # walk the JSON document, get the actual document location
  def find_nodeinfo_url(body)
    links = JSON.parse(body)
    links.fetch("links").find { |entry|
      entry.fetch("rel") == NODEINFO_SCHEMA
    }.fetch("href")
  end

  # walk the JSON document, find the version string
  def find_software_version(body)
    info = JSON.parse(body)
    sw = info.fetch("software")
    @result.software_version = "#{sw.fetch('name')} #{sw.fetch('version')}"
  end

  class Failure < StandardError
  end

  class AddressFailure < Failure
  end

  class DNSFailure < Failure
  end

  class NetFailure < Failure
  end

  class SSLFailure < Failure
  end

  class HTTPFailure < Failure
  end

  class NodeInfoFailure < Failure
  end

  Result = Struct.new(
    :hostname, :ip, :reachable, :ssl_status, :status_code, :rt, :software_version, :error
  ) do
    # @!attribute hostname
    #   @return [String] hostname derived from the URL

    # @!attribute ip
    #   @return [String] resolved IP address from DNS query

    # @!attribute reachable
    #   @return [Boolean] whether the host was reachable over the network

    # @!attribute ssl_status
    #   @return [Boolean] indicating how the SSL verification went

    # @!attribute status_code
    #   @return [Integer] HTTP status code that was returned for the HEAD request

    # @!attribute rt
    #   @return [Integer] response time for the HTTP request

    # @!attribute software_version
    #   @return [String] version of diaspora* as reported by nodeinfo

    # @!attribute error
    #   @return [Exception] if the test is unsuccessful, this will contain
    #                       an exception of type {ConnectionTester::Failure}

    def initialize
      self.rt = -1
    end

    def success?
      error.nil?
    end

    def error?
      !error.nil?
    end

    def failure_message
      "#{error.class.name}: #{error.message}" if error?
    end
  end
end
