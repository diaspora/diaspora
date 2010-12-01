require 'digest/md5'

module Rack
  # Automatically sets the ETag header on all String bodies
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if !headers.has_key?('ETag')
        digest, body = digest_body(body)
        headers['ETag'] = %("#{digest}")
      end

      [status, headers, body]
    end

    private
      def digest_body(body)
        digest = Digest::MD5.new
        parts = []
        body.each do |part|
          digest << part
          parts << part
        end
        [digest.hexdigest, parts]
      end
  end
end
