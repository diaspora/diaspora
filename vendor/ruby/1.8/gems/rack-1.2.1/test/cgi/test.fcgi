#!/usr/bin/env ruby
# -*- ruby -*-

$:.unshift '../../lib'
require 'rack'
require '../testrequest'

Rack::Handler::FastCGI.run(Rack::Lint.new(TestRequest.new))
