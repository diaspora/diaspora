#!/usr/bin/env ruby
# 
# == Cloud Files API
# ==== Connects Ruby Applications to Rackspace's {Cloud Files service}[http://www.rackspacecloud.com/cloud_hosting_products/files]
# Initial work by Major Hayden <major.hayden@rackspace.com>
# 
# Subsequent work by H. Wade Minter <minter@lunenburg.org>
#
# See COPYING for license information.
# Copyright (c) 2009, Rackspace US, Inc.
# ----
# 
# === Documentation & Examples
# To begin reviewing the available methods and examples, peruse the README file, or begin by looking at documentation for the 
# CloudFiles::Connection class.
#
# The CloudFiles class is the base class.  Not much of note happens here.
# To create a new CloudFiles connection, use the CloudFiles::Connection.new('user_name', 'api_key') method.
module CloudFiles

  VERSION = IO.read(File.dirname(__FILE__) + '/../VERSION')
  require 'net/http'
  require 'net/https'
  require 'rexml/document'
  require 'uri'
  require 'digest/md5'
  require 'time'
  require 'rubygems'
  require 'mime/types'

  unless "".respond_to? :each_char
    require "jcode"
    $KCODE = 'u'
  end

  $:.unshift(File.dirname(__FILE__))
  require 'cloudfiles/authentication'
  require 'cloudfiles/connection'
  require 'cloudfiles/container'
  require 'cloudfiles/storage_object'

  def self.lines(str)
    (str.respond_to?(:lines) ? str.lines : str).to_a.map { |x| x.chomp }
  end
end



class SyntaxException             < StandardError # :nodoc:
end
class ConnectionException         < StandardError # :nodoc:
end
class AuthenticationException     < StandardError # :nodoc:
end
class InvalidResponseException    < StandardError # :nodoc:
end
class NonEmptyContainerException  < StandardError # :nodoc:
end
class NoSuchObjectException       < StandardError # :nodoc:
end
class NoSuchContainerException    < StandardError # :nodoc:
end
class NoSuchAccountException      < StandardError # :nodoc:
end
class MisMatchedChecksumException < StandardError # :nodoc:
end
class IOException                 < StandardError # :nodoc:
end
class CDNNotEnabledException      < StandardError # :nodoc:
end
class ObjectExistsException       < StandardError # :nodoc:
end
class ExpiredAuthTokenException   < StandardError # :nodoc:
end
