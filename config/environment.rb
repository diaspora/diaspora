#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

# Load facebook connection application credentials
fb_config  = YAML::load(File.open(File.expand_path("./config/fb_config.yml")))
FB_API_KEY = fb_config['fb_api_key']
FB_SECRET  = fb_config['fb_secret']
FB_APP_ID  = fb_config['fb_app_id']
HOST       = fb_config['host']

# Initialize the rails application
Diaspora::Application.initialize!

