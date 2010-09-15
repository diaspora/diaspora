#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#use Rack::FiberPool
#require 'lib/chrome_frame'
#use Rack::ChromeFrame
run Diaspora::Application
