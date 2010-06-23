# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
# Initialize the rails application
Diaspora::Application.initialize!
