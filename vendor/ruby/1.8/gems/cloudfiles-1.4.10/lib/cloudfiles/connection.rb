module CloudFiles
  class Connection
    # See COPYING for license information.
    # Copyright (c) 2009, Rackspace US, Inc.
    
    # Authentication key provided when the CloudFiles class was instantiated
    attr_reader :authkey

    # Token returned after a successful authentication
    attr_accessor :authtoken

    # Authentication username provided when the CloudFiles class was instantiated
    attr_reader :authuser
    
    # API host to authenticate to
    attr_reader :authurl

    # Hostname of the CDN management server
    attr_accessor :cdnmgmthost

    # Path for managing containers on the CDN management server
    attr_accessor :cdnmgmtpath
    
    # Port number for the CDN server
    attr_accessor :cdnmgmtport
    
    # URI scheme for the CDN server
    attr_accessor :cdnmgmtscheme

    # Hostname of the storage server
    attr_accessor :storagehost

    # Path for managing containers/objects on the storage server
    attr_accessor :storagepath
    
    # Port for managing the storage server
    attr_accessor :storageport
    
    # URI scheme for the storage server
    attr_accessor :storagescheme
    
    # Instance variable that is set when authorization succeeds
    attr_accessor :authok
    
    # The total size in bytes under this connection
    attr_reader :bytes
    
    # The total number of containers under this connection
    attr_reader :count
    
    # Optional proxy variables
    attr_reader :proxy_host
    attr_reader :proxy_port
    
    # Creates a new CloudFiles::Connection object.  Uses CloudFiles::Authentication to perform the login for the connection.
    # The authuser is the Rackspace Cloud username, the authkey is the Rackspace Cloud API key.
    #
    # Setting the optional retry_auth variable to false will cause an exception to be thrown if your authorization token expires.
    # Otherwise, it will attempt to reauthenticate.
    #
    # Setting the optional snet variable to true or setting an environment variable of RACKSPACE_SERVICENET to any value will cause 
    # storage URLs to be returned with a prefix pointing them to the internal Rackspace service network, instead of a public URL.  
    #
    # This is useful if you are using the library on a Rackspace-hosted system, as it provides faster speeds, keeps traffic off of
    # the public network, and the bandwidth is not billed.
    #
    # If you need to connect to a Cloud Files installation that is NOT the standard Rackspace one, set the :authurl option to the URL 
    # of your authentication endpoint.  The default is https://auth.api.rackspacecloud.com/v1.0
    #
    # This will likely be the base class for most operations.
    # 
    # With gem 1.4.8, the connection style has changed.  It is now a hash of arguments.  Note that the proxy options are currently only
    # supported in the new style.
    #
    #   cf = CloudFiles::Connection.new(:username => "MY_USERNAME", :api_key => "MY_API_KEY", :authurl => "https://auth.api.rackspacecloud.com/v1.0", :retry_auth => true, :snet => false, :proxy_host => "localhost", :proxy_port => "1234")
    #
    # The old style (positional arguments) is deprecated and will be removed at some point in the future.
    # 
    #   cf = CloudFiles::Connection.new(MY_USERNAME, MY_API_KEY, RETRY_AUTH, USE_SNET)
    def initialize(*args)
      if args[0].is_a?(Hash)
        options = args[0]
        @authuser = options[:username] ||( raise AuthenticationException, "Must supply a :username")
        @authkey = options[:api_key] || (raise AuthenticationException, "Must supply an :api_key")
        @authurl = options[:authurl] || "https://auth.api.rackspacecloud.com/v1.0"
        @retry_auth = options[:retry_auth] || true
        @snet = ENV['RACKSPACE_SERVICENET'] || options[:snet]
        @proxy_host = options[:proxy_host]
        @proxy_port = options[:proxy_port]
      elsif args[0].is_a?(String)
        @authuser = args[0] ||( raise AuthenticationException, "Must supply the username as the first argument")
        @authkey = args[1] || (raise AuthenticationException, "Must supply the API key as the second argument")
        @retry_auth = args[2] || true
        @snet = (ENV['RACKSPACE_SERVICENET'] || args[3]) ? true : false
        @authurl = "https://auth.api.rackspacecloud.com/v1.0"
      end
      @authok = false
      @http = {}
      CloudFiles::Authentication.new(self)
    end

    # Returns true if the authentication was successful and returns false otherwise.
    #
    #   cf.authok?
    #   => true
    def authok?
      @authok
    end
    
    # Returns true if the library is requesting the use of the Rackspace service network
    def snet?
      @snet
    end

    # Returns an CloudFiles::Container object that can be manipulated easily.  Throws a NoSuchContainerException if
    # the container doesn't exist.
    #
    #    container = cf.container('test')
    #    container.count
    #    => 2
    def container(name)
      CloudFiles::Container.new(self,name)
    end
    alias :get_container :container

    # Sets instance variables for the bytes of storage used for this account/connection, as well as the number of containers
    # stored under the account.  Returns a hash with :bytes and :count keys, and also sets the instance variables.
    #
    #   cf.get_info
    #   => {:count=>8, :bytes=>42438527}
    #   cf.bytes
    #   => 42438527    
    def get_info
      response = cfreq("HEAD",@storagehost,@storagepath,@storageport,@storagescheme)
      raise InvalidResponseException, "Unable to obtain account size" unless (response.code == "204")
      @bytes = response["x-account-bytes-used"].to_i
      @count = response["x-account-container-count"].to_i
      {:bytes => @bytes, :count => @count}
    end
    
    # Gathers a list of the containers that exist for the account and returns the list of container names
    # as an array.  If no containers exist, an empty array is returned.  Throws an InvalidResponseException
    # if the request fails.
    #
    # If you supply the optional limit and marker parameters, the call will return the number of containers
    # specified in limit, starting after the object named in marker.
    #
    #   cf.containers
    #   => ["backup", "Books", "cftest", "test", "video", "webpics"] 
    #
    #   cf.containers(2,'cftest')
    #   => ["test", "video"]
    def containers(limit=0,marker="")
      paramarr = []
      paramarr << ["limit=#{URI.encode(limit.to_s).gsub(/&/,'%26')}"] if limit.to_i > 0
      paramarr << ["marker=#{URI.encode(marker.to_s).gsub(/&/,'%26')}"] unless marker.to_s.empty?
      paramstr = (paramarr.size > 0)? paramarr.join("&") : "" ;
      response = cfreq("GET",@storagehost,"#{@storagepath}?#{paramstr}",@storageport,@storagescheme)
      return [] if (response.code == "204")
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code == "200")
      CloudFiles.lines(response.body)
    end
    alias :list_containers :containers

    # Retrieves a list of containers on the account along with their sizes (in bytes) and counts of the objects
    # held within them.  If no containers exist, an empty hash is returned.  Throws an InvalidResponseException
    # if the request fails.
    #
    # If you supply the optional limit and marker parameters, the call will return the number of containers
    # specified in limit, starting after the object named in marker.
    # 
    #   cf.containers_detail              
    #   => { "container1" => { :bytes => "36543", :count => "146" }, 
    #        "container2" => { :bytes => "105943", :count => "25" } }
    def containers_detail(limit=0,marker="")
      paramarr = []
      paramarr << ["limit=#{URI.encode(limit.to_s).gsub(/&/,'%26')}"] if limit.to_i > 0
      paramarr << ["marker=#{URI.encode(marker.to_s).gsub(/&/,'%26')}"] unless marker.to_s.empty?
      paramstr = (paramarr.size > 0)? paramarr.join("&") : "" ;
      response = cfreq("GET",@storagehost,"#{@storagepath}?format=xml&#{paramstr}",@storageport,@storagescheme)
      return {} if (response.code == "204")
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code == "200")
      doc = REXML::Document.new(response.body)
      detailhash = {}
      doc.elements.each("account/container/") { |c|
        detailhash[c.elements["name"].text] = { :bytes => c.elements["bytes"].text, :count => c.elements["count"].text  }
      }
      doc = nil
      return detailhash
    end
    alias :list_containers_info :containers_detail

    # Returns true if the requested container exists and returns false otherwise.
    # 
    #   cf.container_exists?('good_container')
    #   => true
    #  
    #   cf.container_exists?('bad_container')
    #   => false
    def container_exists?(containername)
      response = cfreq("HEAD",@storagehost,"#{@storagepath}/#{URI.encode(containername).gsub(/&/,'%26')}",@storageport,@storagescheme)
      return (response.code == "204")? true : false ;
    end

    # Creates a new container and returns the CloudFiles::Container object.  Throws an InvalidResponseException if the 
    # request fails.
    #
    # Slash (/) and question mark (?) are invalid characters, and will be stripped out.  The container name is limited to 
    # 256 characters or less.
    #
    #   container = cf.create_container('new_container')
    #   container.name
    #   => "new_container"
    #
    #   container = cf.create_container('bad/name')
    #   => SyntaxException: Container name cannot contain the characters '/' or '?'
    def create_container(containername)
      raise SyntaxException, "Container name cannot contain the characters '/' or '?'" if containername.match(/[\/\?]/)
      raise SyntaxException, "Container name is limited to 256 characters" if containername.length > 256
      response = cfreq("PUT",@storagehost,"#{@storagepath}/#{URI.encode(containername).gsub(/&/,'%26')}",@storageport,@storagescheme)
      raise InvalidResponseException, "Unable to create container #{containername}" unless (response.code == "201" || response.code == "202")
      CloudFiles::Container.new(self,containername)
    end

    # Deletes a container from the account.  Throws a NonEmptyContainerException if the container still contains
    # objects.  Throws a NoSuchContainerException if the container doesn't exist.
    # 
    #   cf.delete_container('new_container')
    #   => true
    #
    #   cf.delete_container('video')
    #   => NonEmptyContainerException: Container video is not empty
    #
    #   cf.delete_container('nonexistent')
    #   => NoSuchContainerException: Container nonexistent does not exist
    def delete_container(containername)
      response = cfreq("DELETE",@storagehost,"#{@storagepath}/#{URI.encode(containername).gsub(/&/,'%26')}",@storageport,@storagescheme)
      raise NonEmptyContainerException, "Container #{containername} is not empty" if (response.code == "409")
      raise NoSuchContainerException, "Container #{containername} does not exist" unless (response.code == "204")
      true
    end

    # Gathers a list of public (CDN-enabled) containers that exist for an account and returns the list of container names
    # as an array.  If no containers are public, an empty array is returned.  Throws a InvalidResponseException if
    # the request fails.
    #
    # If you pass the optional argument as true, it will only show containers that are CURRENTLY being shared on the CDN, 
    # as opposed to the default behavior which is to show all containers that have EVER been public.
    #
    #   cf.public_containers
    #   => ["video", "webpics"]
    def public_containers(enabled_only = false)
      paramstr = enabled_only == true ? "enabled_only=true" : ""
      response = cfreq("GET",@cdnmgmthost,"#{@cdnmgmtpath}?#{paramstr}",@cdnmgmtport,@cdnmgmtscheme)
      return [] if (response.code == "204")
      raise InvalidResponseException, "Invalid response code #{response.code}" unless (response.code == "200")
      CloudFiles.lines(response.body)
    end

    # This method actually makes the HTTP calls out to the server
    def cfreq(method,server,path,port,scheme,headers = {},data = nil,attempts = 0,&block) # :nodoc:
      start = Time.now
      headers['Transfer-Encoding'] = "chunked" if data.is_a?(IO)
      hdrhash = headerprep(headers)
      start_http(server,path,port,scheme,hdrhash)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(path,hdrhash)
      if data
        if data.respond_to?(:read)
          request.body_stream = data
        else
          request.body = data
        end
        unless data.is_a?(IO)
          request.content_length = data.respond_to?(:lstat) ? data.stat.size : data.size
        end
      else
        request.content_length = 0
      end
      response = @http[server].request(request,&block)
      raise ExpiredAuthTokenException if response.code == "401"
      response
    rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
      # Server closed the connection, retry
      raise ConnectionException, "Unable to reconnect to #{server} after #{count} attempts" if attempts >= 5
      attempts += 1
      @http[server].finish
      start_http(server,path,port,scheme,headers)
      retry
    rescue ExpiredAuthTokenException
      raise ConnectionException, "Authentication token expired and you have requested not to retry" if @retry_auth == false
      CloudFiles::Authentication.new(self)
      retry
    end
    
    private
    
    # Sets up standard HTTP headers
    def headerprep(headers = {}) # :nodoc:
      default_headers = {}
      default_headers["X-Auth-Token"] = @authtoken if (authok? && @account.nil?)
      default_headers["X-Storage-Token"] = @authtoken if (authok? && !@account.nil?)
      default_headers["Connection"] = "Keep-Alive"
      default_headers["User-Agent"] = "CloudFiles Ruby API #{VERSION}"
      default_headers.merge(headers)
    end
    
    # Starts (or restarts) the HTTP connection
    def start_http(server,path,port,scheme,headers) # :nodoc:
      if (@http[server].nil?)
        begin
          @http[server] = Net::HTTP::Proxy(self.proxy_host, self.proxy_port).new(server,port)
          if scheme == "https"
            @http[server].use_ssl = true
            @http[server].verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          @http[server].start
        rescue
          raise ConnectionException, "Unable to connect to #{server}"
        end
      end
    end

  end

end
