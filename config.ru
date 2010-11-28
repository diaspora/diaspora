#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#use Rack::FiberPool
require ::File.expand_path('../lib/chrome_frame', __FILE__)
use Rack::ChromeFrame
run Diaspora::Application
