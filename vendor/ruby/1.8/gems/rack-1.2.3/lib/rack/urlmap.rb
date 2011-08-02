module Rack
  # Rack::URLMap takes a hash mapping urls or paths to apps, and
  # dispatches accordingly.  Support for HTTP/1.1 host names exists if
  # the URLs start with <tt>http://</tt> or <tt>https://</tt>.
  #
  # URLMap modifies the SCRIPT_NAME and PATH_INFO such that the part
  # relevant for dispatch is in the SCRIPT_NAME, and the rest in the
  # PATH_INFO.  This should be taken care of when you need to
  # reconstruct the URL in order to create links.
  #
  # URLMap dispatches in such a way that the longest paths are tried
  # first, since they are most specific.

  class URLMap
    def initialize(map = {})
      remap(map)
    end

    def remap(map)
      @mapping = map.map { |location, app|
        if location =~ %r{\Ahttps?://(.*?)(/.*)}
          host, location = $1, $2
        else
          host = nil
        end

        unless location[0] == ?/
          raise ArgumentError, "paths need to start with /"
        end
        location = location.chomp('/')
        match = Regexp.new("^#{Regexp.quote(location).gsub('/', '/+')}(.*)", nil, 'n')

        [host, location, match, app]
      }.sort_by { |(h, l, m, a)| [h ? -h.size : (-1.0 / 0.0), -l.size] }  # Longest path first
    end

    def call(env)
      path = env["PATH_INFO"]
      script_name = env['SCRIPT_NAME']
      hHost, sName, sPort = env.values_at('HTTP_HOST','SERVER_NAME','SERVER_PORT')
      @mapping.each { |host, location, match, app|
        next unless (hHost == host || sName == host \
          || (host.nil? && (hHost == sName || hHost == sName+':'+sPort)))
        next unless path.to_s =~ match && rest = $1
        next unless rest.empty? || rest[0] == ?/
        env.merge!('SCRIPT_NAME' => (script_name + location), 'PATH_INFO' => rest)
        return app.call(env)
      }
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]
    ensure
      env.merge! 'PATH_INFO' => path, 'SCRIPT_NAME' => script_name
    end
  end
end

