#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true
# Initialize the rails application
Diaspora::Application.initialize!


