require 'rubygems'
require File.dirname(__FILE__) + '/culerity/celerity_server'
Culerity::CelerityServer.new(STDIN, STDOUT)
