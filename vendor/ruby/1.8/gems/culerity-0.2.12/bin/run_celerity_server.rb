#!/usr/bin/env jruby
require File.dirname(__FILE__) << '/../lib/culerity/celerity_server'
Culerity::CelerityServer.new(STDIN, STDOUT)

