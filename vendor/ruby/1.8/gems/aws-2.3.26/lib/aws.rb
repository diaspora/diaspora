
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
require 'awsbase/aws_response_array'
require 'ec2/right_ec2'
require 'ec2/right_mon_interface'
require 's3/right_s3_interface'
require 's3/right_s3'
require 'sqs/right_sqs_interface'
require 'sqs/right_sqs'
require 'sdb/right_sdb_interface'
require 'acf/right_acf_interface'
require 'elb/elb_interface'
require 'rds/rds'
require 'iam/iam'

