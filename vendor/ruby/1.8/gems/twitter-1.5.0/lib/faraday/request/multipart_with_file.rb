require 'faraday'

# @private
module Faraday
  # @private
  class Request::MultipartWithFile < Faraday::Middleware
    def call(env)
      if env[:body].is_a?(Hash)
        env[:body].each do |key, value|
          if value.is_a?(File)
            env[:body][key] = Faraday::UploadIO.new(value, mime_type(value), value.path)
          end
        end
      end

      @app.call(env)
    end

    private

    def mime_type(file)
      case file.path
        when /\.jpe?g/i then 'image/jpeg'
        when /\.gif$/i then 'image/gif'
        when /\.png$/i then 'image/png'
        else 'application/octet-stream'
      end
    end
  end
end
