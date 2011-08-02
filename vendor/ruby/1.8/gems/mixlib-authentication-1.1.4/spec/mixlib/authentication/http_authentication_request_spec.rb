# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..','..','spec_helper'))

require 'mixlib/authentication'
require 'mixlib/authentication/http_authentication_request'
require 'ostruct'
require 'pp'

describe Mixlib::Authentication::HTTPAuthenticationRequest do
  before do
    request = Struct.new(:env, :method, :path)

    @timestamp_iso8601 = "2009-01-01T12:00:00Z"
    @x_ops_content_hash = "DFteJZPVv6WKdQmMqZUQUumUyRs="
    @user_id = "spec-user"
    @http_x_ops_lines = [
      "jVHrNniWzpbez/eGWjFnO6lINRIuKOg40ZTIQudcFe47Z9e/HvrszfVXlKG4",
      "NMzYZgyooSvU85qkIUmKuCqgG2AIlvYa2Q/2ctrMhoaHhLOCWWoqYNMaEqPc",
      "3tKHE+CfvP+WuPdWk4jv4wpIkAz6ZLxToxcGhXmZbXpk56YTmqgBW2cbbw4O",
      "IWPZDHSiPcw//AYNgW1CCDptt+UFuaFYbtqZegcBd2n/jzcWODA7zL4KWEUy",
      "9q4rlh/+1tBReg60QdsmDRsw/cdO1GZrKtuCwbuD4+nbRdVBKv72rqHX9cu0",
      "utju9jzczCyB+sSAQWrxSsXB/b8vV2qs0l4VD2ML+w=="]
    @merb_headers = {
      # These are used by signatureverification. An arbitrary sampling of non-HTTP_*
      # headers are in here to exercise that code path.
      "HTTP_HOST"=>"127.0.0.1", 
      "HTTP_X_OPS_SIGN"=>"version=1.0",
      "HTTP_X_OPS_REQUESTID"=>"127.0.0.1 1258566194.85386", 
      "HTTP_X_OPS_TIMESTAMP"=>@timestamp_iso8601, 
      "HTTP_X_OPS_CONTENT_HASH"=>@x_ops_content_hash, 
      "HTTP_X_OPS_USERID"=>@user_id, 
      "HTTP_X_OPS_AUTHORIZATION_1"=>@http_x_ops_lines[0], 
      "HTTP_X_OPS_AUTHORIZATION_2"=>@http_x_ops_lines[1], 
      "HTTP_X_OPS_AUTHORIZATION_3"=>@http_x_ops_lines[2], 
      "HTTP_X_OPS_AUTHORIZATION_4"=>@http_x_ops_lines[3], 
      "HTTP_X_OPS_AUTHORIZATION_5"=>@http_x_ops_lines[4], 
      "HTTP_X_OPS_AUTHORIZATION_6"=>@http_x_ops_lines[5], 

      # Random sampling
      "REMOTE_ADDR"=>"127.0.0.1", 
      "PATH_INFO"=>"/organizations/local-test-org/cookbooks", 
      "REQUEST_PATH"=>"/organizations/local-test-org/cookbooks", 
      "CONTENT_TYPE"=>"multipart/form-data; boundary=----RubyMultipartClient6792ZZZZZ",
      "CONTENT_LENGTH"=>"394", 
    }
    @request = request.new(@merb_headers, "POST", '/nodes')
    @http_authentication_request = Mixlib::Authentication::HTTPAuthenticationRequest.new(@request)
  end

  it "normalizes the headers to lowercase symbols" do
    expected = {:host=>"127.0.0.1",
                :x_ops_sign=>"version=1.0",
                :x_ops_requestid=>"127.0.0.1 1258566194.85386",
                :x_ops_timestamp=>"2009-01-01T12:00:00Z",
                :x_ops_content_hash=>"DFteJZPVv6WKdQmMqZUQUumUyRs=",
                :x_ops_userid=>"spec-user",
                :x_ops_authorization_1=>"jVHrNniWzpbez/eGWjFnO6lINRIuKOg40ZTIQudcFe47Z9e/HvrszfVXlKG4",
                :x_ops_authorization_2=>"NMzYZgyooSvU85qkIUmKuCqgG2AIlvYa2Q/2ctrMhoaHhLOCWWoqYNMaEqPc",
                :x_ops_authorization_3=>"3tKHE+CfvP+WuPdWk4jv4wpIkAz6ZLxToxcGhXmZbXpk56YTmqgBW2cbbw4O",
                :x_ops_authorization_4=>"IWPZDHSiPcw//AYNgW1CCDptt+UFuaFYbtqZegcBd2n/jzcWODA7zL4KWEUy",
                :x_ops_authorization_5=>"9q4rlh/+1tBReg60QdsmDRsw/cdO1GZrKtuCwbuD4+nbRdVBKv72rqHX9cu0",
                :x_ops_authorization_6=>"utju9jzczCyB+sSAQWrxSsXB/b8vV2qs0l4VD2ML+w=="}
    @http_authentication_request.headers.should == expected
  end

  it "raises an error when not all required headers are given" do
    @merb_headers.delete("HTTP_X_OPS_SIGN")
    exception = Mixlib::Authentication::MissingAuthenticationHeader
    auth_req = Mixlib::Authentication::HTTPAuthenticationRequest.new(@request)
    lambda {auth_req.validate_headers!}.should raise_error(exception)
  end

  it "extracts the path from the request" do
    @http_authentication_request.path.should == '/nodes'
  end

  it "extracts the request method from the request" do
    @http_authentication_request.http_method.should == 'POST'
  end

  it "extracts the signing description from the request headers" do
    @http_authentication_request.signing_description.should == 'version=1.0'
  end

  it "extracts the user_id from the request headers" do
    @http_authentication_request.user_id.should == 'spec-user'
  end

  it "extracts the timestamp from the request headers" do
    @http_authentication_request.timestamp.should == "2009-01-01T12:00:00Z"
  end

  it "extracts the host from the request headers" do
    @http_authentication_request.host.should == "127.0.0.1"
  end

  it "extracts the content hash from the request headers" do
    @http_authentication_request.content_hash.should == "DFteJZPVv6WKdQmMqZUQUumUyRs="
  end

  it "rebuilds the request signature from the headers" do
    expected=<<-SIG
jVHrNniWzpbez/eGWjFnO6lINRIuKOg40ZTIQudcFe47Z9e/HvrszfVXlKG4
NMzYZgyooSvU85qkIUmKuCqgG2AIlvYa2Q/2ctrMhoaHhLOCWWoqYNMaEqPc
3tKHE+CfvP+WuPdWk4jv4wpIkAz6ZLxToxcGhXmZbXpk56YTmqgBW2cbbw4O
IWPZDHSiPcw//AYNgW1CCDptt+UFuaFYbtqZegcBd2n/jzcWODA7zL4KWEUy
9q4rlh/+1tBReg60QdsmDRsw/cdO1GZrKtuCwbuD4+nbRdVBKv72rqHX9cu0
utju9jzczCyB+sSAQWrxSsXB/b8vV2qs0l4VD2ML+w==
SIG
    @http_authentication_request.request_signature.should == expected.chomp
  end

end