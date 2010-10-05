#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

## Defines available packages

package :ruby do
  description 'Ruby Virtual Machine'
  version '1.9.2'
  patchlevel '0'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{version}-p#{patchlevel}.tar.gz"
  requires :ruby_dependencies
end

package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  apt %w( bison zlib1g-dev libssl-dev libreadline5-dev libncurses5-dev file )
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.3.7'
  source "http://production.cf.rubygems.org/rubygems/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  run( "PATH=$PATH:/var/lib/gems/1.9/bin")
  run( "export PATH")
  requires :ruby
end

package :bundler do
  description 'bundler'
  version '1.0.0'
  gem 'bundler'
  requires :rubygems
end

package :diaspora_dependencies do
  description 'random dependencies'
  apt %w(libxslt1.1 libxslt1-dev libxml2 imagemagick libmagick9-dev)
end
#package :diaspora do
#  description 'Diaspora'

=begin
package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '>=3.0.0b4'
end
=end
