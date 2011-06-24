require 'rubygems'
require 'bundler/setup'
require 'rack'

# The project root directory
$root = ::File.dirname(__FILE__)

# Common Rack Middleware
use Rack::ShowStatus      # Nice looking 404s and other messages
use Rack::ShowExceptions  # Nice looking errors

#
# From Rack::DirectoryIndex:
# https://github.com/craigmarksmith/rack-directory-index/
#
module Rack
  class DirectoryIndex
    def initialize(app)
      @app = app
    end
    def call(env)
      index_path = ::File.join($root, 'public', Rack::Request.new(env).path.split('/'), 'index.html')
      if ::File.exists?(index_path)
        return [200, {"Content-Type" => "text/html"}, [::File.read(index_path)]]
      else
        @app.call(env)
      end
    end
  end
end

use Rack::DirectoryIndex

run Rack::Directory.new($root + '/public')

