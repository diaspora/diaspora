#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



# Load the rails application
require_relative 'application'
Haml::Template.options[:format] = :html5
# Initialize the rails application
Diaspora::Application.initialize!


