#!/usr/bin/env sprinkle -s

# Annotated Example Sprinkle Rails deployment script
#
# This is an example Sprinkle script configured to install Rails from gems, Apache, Ruby,
# Sphinx and Git from source, and mysql and Git dependencies from apt on an Ubuntu system.
#
# Installation is configured to run via capistrano (and an accompanying deploy.rb recipe script).
# Source based packages are downloaded and built into /usr/local on the remote system.
#
# A sprinkle script is separated into 3 different sections. Packages, policies and deployment:


# Packages (separate files for brevity)
#
#  Defines the world of packages as we know it. Each package has a name and
#  set of metadata including its installer type (eg. apt, source, gem, etc). Packages can have
#  relationships to each other via dependencies.

require "#{File.dirname(__FILE__)}/packages/essential"
require "#{File.dirname(__FILE__)}/packages/database"
require "#{File.dirname(__FILE__)}/packages/server"
require "#{File.dirname(__FILE__)}/packages/scm"
require "#{File.dirname(__FILE__)}/packages/ruby"
#require "#{File.dirname(__FILE__)}/packages/unfortunately_essential"

# Policies
#
#  Names a group of packages (optionally with versions) that apply to a particular set of roles:
#
#   Associates the rails policy to the application servers. Contains rails, and surrounding
#   packages. Note, appserver, database, webserver and search are all virtual packages defined above.
#   If there's only one implementation of a virtual package, it's selected automatically, otherwise
#   the user is requested to select which one to use.

policy :diaspora, :roles => [:tom, :backer] do
#  requires :clean_dreamhost
#  requires :tools
#  requires :rubygems
#	requires :bundler
#  requires :diaspora_dependencies
#  requires :database
#  requires :webserver
#  requires :scm
  requires :vim
end
=begin

policy :ci, :roles => :ci do
  requires :tools
  requires :rubygems
	requires :bundler
  requires :diaspora_dependencies
  requires :database
  requires :webserver
  requires :scm
  #add sqlite
end

=end
# Deployment
#
#  Defines script wide settings such as a delivery mechanism for executing commands on the target
#  system (eg. capistrano), and installer defaults (eg. build locations, etc):
#
#   Configures spinkle to use capistrano for delivery of commands to the remote machines (via
#   the named 'deploy' recipe). Also configures 'source' installer defaults to put package gear
#   in /usr/local

deployment do

  # mechanism for deployment
  delivery :capistrano do
    recipes "#{File.dirname(__FILE__)}/../deploy"
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
	binary do
		prefix   '/usr/local/bin'
    archives '/usr/local/sources'
  end 
end

# End of script, given the above information, Spinkle will apply the defined policy on all roles using the
# deployment settings specified.
