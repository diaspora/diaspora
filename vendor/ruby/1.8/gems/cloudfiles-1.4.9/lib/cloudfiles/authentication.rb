module CloudFiles
  class Authentication
    # See COPYING for license information.
    # Copyright (c) 2009, Rackspace US, Inc.
    
    # Performs an authentication to the Cloud Files servers.  Opens a new HTTP connection to the API server,
    # sends the credentials, and looks for a successful authentication.  If it succeeds, it sets the cdmmgmthost,
    # cdmmgmtpath, storagehost, storagepath, authtoken, and authok variables on the connection.  If it fails, it raises
    # an AuthenticationException.
    #
    # Should probably never be called directly.
    def initialize(connection)
      parsed_authurl = URI.parse(connection.authurl)
      path = parsed_authurl.path
      hdrhash = { "X-Auth-User" => connection.authuser, "X-Auth-Key" => connection.authkey }
      begin
        server             = get_server(connection, parsed_authurl)
        server.use_ssl     = true
        server.verify_mode = OpenSSL::SSL::VERIFY_NONE
        server.start
      rescue
        raise ConnectionException, "Unable to connect to #{server}"
      end
      response = server.get(path,hdrhash)
      if (response.code == "204")
        connection.cdnmgmthost   = URI.parse(response["x-cdn-management-url"]).host
        connection.cdnmgmtpath   = URI.parse(response["x-cdn-management-url"]).path
        connection.cdnmgmtport   = URI.parse(response["x-cdn-management-url"]).port
        connection.cdnmgmtscheme = URI.parse(response["x-cdn-management-url"]).scheme
        connection.storagehost   = set_snet(connection,URI.parse(response["x-storage-url"]).host)
        connection.storagepath   = URI.parse(response["x-storage-url"]).path
        connection.storageport   = URI.parse(response["x-storage-url"]).port
        connection.storagescheme = URI.parse(response["x-storage-url"]).scheme
        connection.authtoken     = response["x-auth-token"]
        connection.authok        = true
      else
        connection.authtoken = false
        raise AuthenticationException, "Authentication failed"
      end
      server.finish
    end
    
    private
    
    def get_server(connection, parsed_authurl)
      Net::HTTP::Proxy(connection.proxy_host, connection.proxy_port).new(parsed_authurl.host,parsed_authurl.port)
    end
    
    def set_snet(connection,hostname)
      if connection.snet?
        "snet-#{hostname}"
      else
        hostname
      end
    end
  end
end
