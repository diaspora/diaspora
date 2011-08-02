#
# Copyright (c) 2007-2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'benchmark'
require 'net/https'
require 'uri'
require 'time'
require "cgi"
require "base64"
require "rexml/document"
require "openssl"
require "digest/sha1"

require 'rubygems'
require 'right_http_connection'

$:.unshift(File.dirname(__FILE__))
require 'awsbase/benchmark_fix'
require 'awsbase/support'
require 'awsbase/right_awsbase'
require 'ec2/right_ec2'
require 'ec2/right_mon_interface'
require 's3/right_s3_interface'
require 's3/right_s3'
require 'sqs/right_sqs_interface'
require 'sqs/right_sqs'
require 'sdb/right_sdb_interface'
require 'acf/right_acf_interface'
require 'elb/elb_interface'


# backwards compatible.
# @deprecated
module RightAws
    include Aws
    extend Aws
end
