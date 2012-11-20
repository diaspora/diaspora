 #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../lib/unicorn_killer',  __FILE__)
require ::File.expand_path('../lib/rack/chrome_frame',  __FILE__)

# Kill unicorn workers really agressively (at 300mb)
if defined?(Unicorn)
  use UnicornKiller::Oom, 300 * 1024
end
use Rack::Deflater
use Rack::ChromeFrame, :minimum => 8
use Rack::Protection::FrameOptions

run Diaspora::Application
