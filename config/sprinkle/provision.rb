#!/usr/bin/env sprinkle -s
#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.





require "#{File.dirname(__FILE__)}/packages/essential"
require "#{File.dirname(__FILE__)}/packages/database"
require "#{File.dirname(__FILE__)}/packages/server"
require "#{File.dirname(__FILE__)}/packages/scm"
require "#{File.dirname(__FILE__)}/packages/ruby"

policy :diaspora, :roles => [:pivots] do
#  requires :clean_dreamhost
  requires :tools
  requires :rubygems
	requires :bundler
  requires :diaspora_dependencies
  requires :database
  requires :webserver
  requires :scm
  requires :vim
  requires :nginx_conf
end


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

