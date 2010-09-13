#!/usr/bin/env sprinkle -s
#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#





require "#{File.dirname(__FILE__)}/packages/essential"
require "#{File.dirname(__FILE__)}/packages/database"
require "#{File.dirname(__FILE__)}/packages/server"
require "#{File.dirname(__FILE__)}/packages/scm"
require "#{File.dirname(__FILE__)}/packages/ruby"

policy :diaspora, :roles => [:tom,:backer] do
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

