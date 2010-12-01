require 'test/unit'
$: << File.dirname(__FILE__)
require 'test_credentials'
TestCredentials.get_credentials

require 'http_connection'
require 'ec2/test_ec2.rb'
require 's3/test_s3.rb'
require 's3/test_s3_stubbed.rb'
require 'sqs/test_sqs.rb'
require 'sqs/test_right_sqs_gen2.rb'
require 'sdb/test_sdb.rb'
require 'acf/test_acf.rb'
