#
# Author:: Tim Hinderliter (<tim@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2009, 2010 Opscode, Inc.
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
require 'rubygems'

require 'ostruct'
require 'openssl'
require 'mixlib/authentication/signatureverification'
require 'time'

# TODO: should make these regular spec-based mock objects.
class MockRequest
  attr_accessor :env, :params, :path, :raw_post

  def initialize(path, params, headers, raw_post)
    @path = path
    @params = params
    @env = headers
    @raw_post = raw_post
  end

  def method
    "POST"
  end
end

class MockFile
  def initialize
    @have_read = nil
  end

  def self.length
    BODY.length
  end

  def read(len, out_str)
    if @have_read.nil?
      @have_read = 1
      out_str[0..-1] = BODY
      BODY
    else
      nil
    end
  end
end

# Uncomment this to get some more info from the methods we're testing.
#Mixlib::Authentication::Log.logger = Logger.new(STDERR)
#Mixlib::Authentication::Log.level :debug

describe "Mixlib::Authentication::SignedHeaderAuth" do
  it "should generate the correct string to sign and signature" do
    # fix the timestamp, private key and body so we get the same answer back
    # every time.
    args = {
      :body => BODY, 
      :user_id => USER_ID,
      :http_method => :post,
      :timestamp => TIMESTAMP_ISO8601,    # fixed timestamp so we get back the same answer each time.
      :file => MockFile.new,
      :path => PATH,
    }

    private_key = OpenSSL::PKey::RSA.new(PRIVATE_KEY)
      
    signing_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(args)
    
    expected_string_to_sign = <<EOS
Method:POST
Hashed Path:#{HASHED_CANONICAL_PATH}
X-Ops-Content-Hash:#{HASHED_BODY}
X-Ops-Timestamp:#{TIMESTAMP_ISO8601}
X-Ops-UserId:#{USER_ID}
EOS
    signing_obj.canonicalize_request.should == expected_string_to_sign.chomp

    # If you need to regenerate the constants in this test spec, print out
    # the results of res.inspect and copy them as appropriate into the 
    # the constants in this file.
    res = signing_obj.sign(private_key)
    #$stderr.puts "res.inspect = #{res.inspect}"
    res.should == EXPECTED_SIGN_RESULT
  end

  it "should not choke when signing a request for a resource with a long name" do
    args = {
      :body => BODY, 
      :user_id => USER_ID,
      :http_method => :put,
      :timestamp => TIMESTAMP_ISO8601,    # fixed timestamp so we get back the same answer each time.
      :file => MockFile.new,
      :path => PATH + "/nodes/#{"A" * 100}"}

    private_key = OpenSSL::PKey::RSA.new(PRIVATE_KEY)
      
    signing_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(args)
    
    lambda { signing_obj.sign(private_key) }.should_not raise_error
  end
end

describe "Mixlib::Authentication::SignatureVerification" do
  
  before(:each) do
    @user_private_key = OpenSSL::PKey::RSA.new(PRIVATE_KEY)
  end

  it "should authenticate a File-containing request - Merb" do
    request_params = MERB_REQUEST_PARAMS.clone
    request_params["file"] =
      { "size"=>MockFile.length, "content_type"=>"application/octet-stream", "filename"=>"zsh.tar.gz", "tempfile"=>MockFile.new }

    mock_request = MockRequest.new(PATH, request_params, MERB_HEADERS, "")
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ)

    service = Mixlib::Authentication::SignatureVerification.new
    res = service.authenticate_user_request(mock_request, @user_private_key)
    res.should_not be_nil
  end

  it "should authenticate a normal (post body) request - Merb" do
    mock_request = MockRequest.new(PATH, MERB_REQUEST_PARAMS, MERB_HEADERS, BODY)
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ)

    service = Mixlib::Authentication::SignatureVerification.new
    res = service.authenticate_user_request(mock_request, @user_private_key)
    res.should_not be_nil
  end

  it "should authenticate a File-containing request - Passenger" do
    request_params = PASSENGER_REQUEST_PARAMS.clone
    request_params["tarball"] = MockFile.new

    mock_request = MockRequest.new(PATH, request_params, PASSENGER_HEADERS, "")
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ)

    auth_req = Mixlib::Authentication::SignatureVerification.new
    res = auth_req.authenticate_user_request(mock_request, @user_private_key)
    res.should_not be_nil
  end

  it "shouldn't authenticate if an Authorization header is missing" do
    headers = MERB_HEADERS.clone
    headers.delete("HTTP_X_OPS_SIGN")

    mock_request = MockRequest.new(PATH, MERB_REQUEST_PARAMS, headers, BODY)
    Time.stub!(:now).and_return(TIMESTAMP_OBJ)

    auth_req = Mixlib::Authentication::SignatureVerification.new
    lambda {auth_req.authenticate_user_request(mock_request, @user_private_key)}.should raise_error(Mixlib::Authentication::AuthenticationError)

    auth_req.should_not be_a_valid_request
    auth_req.should_not be_a_valid_timestamp
    auth_req.should_not be_a_valid_signature
    auth_req.should_not be_a_valid_content_hash
  end


  it "shouldn't authenticate if Authorization header is wrong" do
    headers = MERB_HEADERS.clone
    headers["HTTP_X_OPS_CONTENT_HASH"] += "_"

    mock_request = MockRequest.new(PATH, MERB_REQUEST_PARAMS, headers, BODY)
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ)

    auth_req = Mixlib::Authentication::SignatureVerification.new
    res = auth_req.authenticate_user_request(mock_request, @user_private_key)
    res.should be_nil

    auth_req.should_not be_a_valid_request
    auth_req.should be_a_valid_timestamp
    auth_req.should be_a_valid_signature
    auth_req.should_not be_a_valid_content_hash
  end

  it "shouldn't authenticate if the timestamp is not within bounds" do
    mock_request = MockRequest.new(PATH, MERB_REQUEST_PARAMS, MERB_HEADERS, BODY)
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ - 1000)

    auth_req = Mixlib::Authentication::SignatureVerification.new
    res = auth_req.authenticate_user_request(mock_request, @user_private_key)
    res.should be_nil
    auth_req.should_not be_a_valid_request
    auth_req.should_not be_a_valid_timestamp
    auth_req.should be_a_valid_signature
    auth_req.should be_a_valid_content_hash
  end

  it "shouldn't authenticate if the signature is wrong" do
    headers =  MERB_HEADERS.dup
    headers["HTTP_X_OPS_AUTHORIZATION_1"] = "epicfail"
    mock_request = MockRequest.new(PATH, MERB_REQUEST_PARAMS, headers, BODY)
    Time.should_receive(:now).at_least(:once).and_return(TIMESTAMP_OBJ)

    auth_req = Mixlib::Authentication::SignatureVerification.new
    res = auth_req.authenticate_user_request(mock_request, @user_private_key)
    res.should be_nil
    auth_req.should_not be_a_valid_request
    auth_req.should_not be_a_valid_signature
    auth_req.should be_a_valid_timestamp
    auth_req.should be_a_valid_content_hash
  end

end

USER_ID = "spec-user"
BODY = "Spec Body"
HASHED_BODY = "DFteJZPVv6WKdQmMqZUQUumUyRs=" # Base64.encode64(Digest::SHA1.digest("Spec Body")).chomp
TIMESTAMP_ISO8601 = "2009-01-01T12:00:00Z"
TIMESTAMP_OBJ = Time.parse("Thu Jan 01 12:00:00 -0000 2009")
PATH = "/organizations/clownco"
HASHED_CANONICAL_PATH = "YtBWDn1blGGuFIuKksdwXzHU9oE=" # Base64.encode64(Digest::SHA1.digest("/organizations/clownco")).chomp

REQUESTING_ACTOR_ID = "c0f8a68c52bffa1020222a56b23cccfa"

# Content hash is ???TODO
X_OPS_CONTENT_HASH = "DFteJZPVv6WKdQmMqZUQUumUyRs="
X_OPS_AUTHORIZATION_LINES = [
  "jVHrNniWzpbez/eGWjFnO6lINRIuKOg40ZTIQudcFe47Z9e/HvrszfVXlKG4",
  "NMzYZgyooSvU85qkIUmKuCqgG2AIlvYa2Q/2ctrMhoaHhLOCWWoqYNMaEqPc",
  "3tKHE+CfvP+WuPdWk4jv4wpIkAz6ZLxToxcGhXmZbXpk56YTmqgBW2cbbw4O",
  "IWPZDHSiPcw//AYNgW1CCDptt+UFuaFYbtqZegcBd2n/jzcWODA7zL4KWEUy",
  "9q4rlh/+1tBReg60QdsmDRsw/cdO1GZrKtuCwbuD4+nbRdVBKv72rqHX9cu0",
  "utju9jzczCyB+sSAQWrxSsXB/b8vV2qs0l4VD2ML+w=="
]

# We expect Mixlib::Authentication::SignedHeaderAuth#sign to return this
# if passed the BODY above.
EXPECTED_SIGN_RESULT = {
  "X-Ops-Content-Hash"=>X_OPS_CONTENT_HASH,
  "X-Ops-Userid"=>USER_ID,
  "X-Ops-Sign"=>"version=1.0",
  "X-Ops-Authorization-1"=>X_OPS_AUTHORIZATION_LINES[0],
  "X-Ops-Authorization-2"=>X_OPS_AUTHORIZATION_LINES[1],
  "X-Ops-Authorization-3"=>X_OPS_AUTHORIZATION_LINES[2],
  "X-Ops-Authorization-4"=>X_OPS_AUTHORIZATION_LINES[3],
  "X-Ops-Authorization-5"=>X_OPS_AUTHORIZATION_LINES[4],
  "X-Ops-Authorization-6"=>X_OPS_AUTHORIZATION_LINES[5],
  "X-Ops-Timestamp"=>TIMESTAMP_ISO8601
}

# This is what will be in request.params for the Merb case.
MERB_REQUEST_PARAMS = {
  "name"=>"zsh", "action"=>"create", "controller"=>"chef_server_api/cookbooks", 
  "organization_id"=>"local-test-org", "requesting_actor_id"=>REQUESTING_ACTOR_ID,
}

# Tis is what will be in request.env for the Merb case.
MERB_HEADERS = {
  # These are used by signatureverification. An arbitrary sampling of non-HTTP_*
  # headers are in here to exercise that code path.
  "HTTP_HOST"=>"127.0.0.1", 
  "HTTP_X_OPS_SIGN"=>"version=1.0",
  "HTTP_X_OPS_REQUESTID"=>"127.0.0.1 1258566194.85386", 
  "HTTP_X_OPS_TIMESTAMP"=>TIMESTAMP_ISO8601, 
  "HTTP_X_OPS_CONTENT_HASH"=>X_OPS_CONTENT_HASH, 
  "HTTP_X_OPS_USERID"=>USER_ID, 
  "HTTP_X_OPS_AUTHORIZATION_1"=>X_OPS_AUTHORIZATION_LINES[0], 
  "HTTP_X_OPS_AUTHORIZATION_2"=>X_OPS_AUTHORIZATION_LINES[1], 
  "HTTP_X_OPS_AUTHORIZATION_3"=>X_OPS_AUTHORIZATION_LINES[2], 
  "HTTP_X_OPS_AUTHORIZATION_4"=>X_OPS_AUTHORIZATION_LINES[3], 
  "HTTP_X_OPS_AUTHORIZATION_5"=>X_OPS_AUTHORIZATION_LINES[4], 
  "HTTP_X_OPS_AUTHORIZATION_6"=>X_OPS_AUTHORIZATION_LINES[5], 

  # Random sampling
  "REMOTE_ADDR"=>"127.0.0.1", 
  "PATH_INFO"=>"/organizations/local-test-org/cookbooks", 
  "REQUEST_PATH"=>"/organizations/local-test-org/cookbooks", 
  "CONTENT_TYPE"=>"multipart/form-data; boundary=----RubyMultipartClient6792ZZZZZ",
  "CONTENT_LENGTH"=>"394", 
}

PASSENGER_REQUEST_PARAMS = {
  "action"=>"create",
  #"tarball"=>#<File:/tmp/RackMultipart20091120-25570-mgq2sa-0>,
  "controller"=>"api/v1/cookbooks",
  "cookbook"=>"{\"category\":\"databases\"}",
}

PASSENGER_HEADERS = {
  # These are used by signatureverification. An arbitrary sampling of non-HTTP_*
  # headers are in here to exercise that code path.
  "HTTP_HOST"=>"127.0.0.1", 
  "HTTP_X_OPS_SIGN"=>"version=1.0",
  "HTTP_X_OPS_REQUESTID"=>"127.0.0.1 1258566194.85386", 
  "HTTP_X_OPS_TIMESTAMP"=>TIMESTAMP_ISO8601, 
  "HTTP_X_OPS_CONTENT_HASH"=>X_OPS_CONTENT_HASH, 
  "HTTP_X_OPS_USERID"=>USER_ID, 
  "HTTP_X_OPS_AUTHORIZATION_1"=>X_OPS_AUTHORIZATION_LINES[0], 
  "HTTP_X_OPS_AUTHORIZATION_2"=>X_OPS_AUTHORIZATION_LINES[1], 
  "HTTP_X_OPS_AUTHORIZATION_3"=>X_OPS_AUTHORIZATION_LINES[2], 
  "HTTP_X_OPS_AUTHORIZATION_4"=>X_OPS_AUTHORIZATION_LINES[3], 
  "HTTP_X_OPS_AUTHORIZATION_5"=>X_OPS_AUTHORIZATION_LINES[4], 
  "HTTP_X_OPS_AUTHORIZATION_6"=>X_OPS_AUTHORIZATION_LINES[5], 

  # Random set of other headers to exercirse the non- HTTP_ code path
  "HTTP_ACCEPT"=>"application/json",
  "SERVER_SOFTWARE"=>"Apache",
  "SCRIPT_URI"=>"http://com-stg.opscode.com/api/v1/cookbooks",
  "SCRIPT_NAME"=>"",
  "SERVER_ADDR"=>"10.242.197.174",
  "SERVER_NAME"=>"com-stg.opscode.com",
  "DOCUMENT_ROOT"=>"/srv/opscode-community/current/public",
}

# generated with
#   openssl genrsa -out private.pem 2048
#   openssl rsa -in private.pem -out public.pem -pubout
PUBLIC_KEY = <<EOS
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0ueqo76MXuP6XqZBILFz
iH/9AI7C6PaN5W0dSvkr9yInyGHSz/IR1+4tqvP2qlfKVKI4CP6BFH251Ft9qMUB
uAsnlAVQ1z0exDtIFFOyQCdR7iXmjBIWMSS4buBwRQXwDK7id1OxtU23qVJv+xwE
V0IzaaSJmaGLIbvRBD+qatfUuQJBMU/04DdJIwvLtZBYdC2219m5dUBQaa4bimL+
YN9EcsDzD9h9UxQo5ReK7b3cNMzJBKJWLzFBcJuePMzAnLFktr/RufX4wpXe6XJx
oVPaHo72GorLkwnQ0HYMTY8rehT4mDi1FI969LHCFFaFHSAaRnwdXaQkJmSfcxzC
YQIDAQAB
-----END PUBLIC KEY-----
EOS

PRIVATE_KEY = <<EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0ueqo76MXuP6XqZBILFziH/9AI7C6PaN5W0dSvkr9yInyGHS
z/IR1+4tqvP2qlfKVKI4CP6BFH251Ft9qMUBuAsnlAVQ1z0exDtIFFOyQCdR7iXm
jBIWMSS4buBwRQXwDK7id1OxtU23qVJv+xwEV0IzaaSJmaGLIbvRBD+qatfUuQJB
MU/04DdJIwvLtZBYdC2219m5dUBQaa4bimL+YN9EcsDzD9h9UxQo5ReK7b3cNMzJ
BKJWLzFBcJuePMzAnLFktr/RufX4wpXe6XJxoVPaHo72GorLkwnQ0HYMTY8rehT4
mDi1FI969LHCFFaFHSAaRnwdXaQkJmSfcxzCYQIDAQABAoIBAQCW3I4sKN5B9jOe
xq/pkeWBq4OvhW8Ys1yW0zFT8t6nHbB1XrwscQygd8gE9BPqj3e0iIEqtdphbPmj
VHqTYbC0FI6QDClifV7noTwTBjeIOlgZ0NSUN0/WgVzIOxUz2mZ2vBZUovKILPqG
TOi7J7RXMoySMdcXpP1f+PgvYNcnKsT72UcWaSXEV8/zo+Zm/qdGPVWwJonri5Mp
DVm5EQSENBiRyt028rU6ElXORNmoQpVjDVqZ1gipzXkifdjGyENw2rt4V/iKYD7V
5iqXOsvP6Cemf4gbrjunAgDG08S00kiUgvVWcdXW+dlsR2nCvH4DOEe3AYYh/aH8
DxEE7FbtAoGBAPcNO8fJ56mNw0ow4Qg38C+Zss/afhBOCfX4O/SZKv/roRn5+gRM
KRJYSVXNnsjPI1plzqR4OCyOrjAhtuvL4a0DinDzf1+fiztyNohwYsW1vYmqn3ti
EN0GhSgE7ppZjqvLQ3f3LUTxynhA0U+k9wflb4irIlViTUlCsOPkrNJDAoGBANqL
Q+vvuGSsmRLU/Cenjy+Mjj6+QENg51dz34o8JKuVKIPKU8pNnyeLa5fat0qD2MHm
OB9opeQOcw0dStodxr6DB3wi83bpjeU6BWUGITNiWEaZEBrQ0aiqNJJKrrHm8fAZ
9o4l4oHc4hI0kYVYYDuxtKuVJrzZiEapTwoOcYiLAoGBAI/EWbeIHZIj9zOjgjEA
LHvm25HtulLOtyk2jd1njQhlHNk7CW2azIPqcLLH99EwCYi/miNH+pijZ2aHGCXb
/bZrSxM0ADmrZKDxdB6uGCyp+GS2sBxjEyEsfCyvwhJ8b3Q100tqwiNO+d5FCglp
HICx2dgUjuRVUliBwOK93nx1AoGAUI8RhIEjOYkeDAESyhNMBr0LGjnLOosX+/as
qiotYkpjWuFULbibOFp+WMW41vDvD9qrSXir3fstkeIAW5KqVkO6mJnRoT3Knnra
zjiKOITCAZQeiaP8BO5o3pxE9TMqb9VCO3ffnPstIoTaN4syPg7tiGo8k1SklVeH
2S8lzq0CgYAKG2fljIYWQvGH628rp4ZcXS4hWmYohOxsnl1YrszbJ+hzR+IQOhGl
YlkUQYXhy9JixmUUKtH+NXkKX7Lyc8XYw5ETr7JBT3ifs+G7HruDjVG78EJVojbd
8uLA+DdQm5mg4vd1GTiSK65q/3EeoBlUaVor3HhLFki+i9qpT8CBsg==
-----END RSA PRIVATE KEY-----
EOS
