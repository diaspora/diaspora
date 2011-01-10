#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../lib/chrome_frame', __FILE__)
require ::File.expand_path('../lib/host-meta', __FILE__)

map "/.well-known" do
  run HostMeta::File.new( "public/well-known")
end

use Rack::ChromeFrame, :minimum => 8
run Diaspora::Application
