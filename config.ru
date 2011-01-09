#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../lib/chrome_frame', __FILE__)
require 'lib/host-meta'
#use Rack::FiberPool

map "/.well-known" do
  run HostMeta::File.new( "public/well-known")
end

map AppConfig[:pod_uri].path  do
  use Rack::ChromeFrame, :minimum => 8
  use Rack::ShowExceptions
  run Diaspora::Application
end
