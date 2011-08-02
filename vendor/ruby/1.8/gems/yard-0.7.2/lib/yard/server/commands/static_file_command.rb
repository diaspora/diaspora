require 'webrick/httputils'

module YARD
  module Server
    module Commands
      # Serves static content when no other router matches a request
      class StaticFileCommand < Base
        include WEBrick::HTTPUtils

        DefaultMimeTypes['js'] = 'text/javascript'

        # Defines the paths used to search for static assets. To define an
        # extra path, use {YARD::Server.register_static_path} rather than
        # modifying this constant directly. Also note that files in the
        # document root will always take precedence over these paths.
        STATIC_PATHS = [
          File.join(YARD::TEMPLATE_ROOT, 'default', 'fulldoc', 'html'),
          File.join(File.dirname(__FILE__), '..', 'templates', 'default', 'fulldoc', 'html')
        ]

        def run
          path = File.cleanpath(request.path).gsub(%r{^(../)+}, '')
          ([adapter.document_root] + STATIC_PATHS.reverse).compact.each do |path_prefix|
            file = File.join(path_prefix, path)
            if File.exist?(file)
              ext = "." + (request.path[/\.(\w+)$/, 1] || "html")
              headers['Content-Type'] = mime_type(ext, DefaultMimeTypes)
              self.body = File.read(file)
              return
            end
          end
          favicon?
          self.status = 404
        end

        private

        # Return an empty favicon.ico if it does not exist so that
        # browsers don't complain.
        def favicon?
          return unless request.path == '/favicon.ico'
          self.headers['Content-Type'] = 'image/png'
          self.status = 200
          self.body = ''
          raise FinishRequest
        end
      end
    end
  end
end