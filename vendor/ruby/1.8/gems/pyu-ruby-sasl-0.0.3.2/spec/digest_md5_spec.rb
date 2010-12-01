require 'sasl'
require 'spec'

describe SASL::DigestMD5 do
  # Preferences from http://tools.ietf.org/html/rfc2831#section-4
  class MyDigestMD5Preferences < SASL::Preferences
    attr_writer :serv_type
    def realm
      'elwood.innosoft.com'
    end
    def digest_uri
      "#{@serv_type}/elwood.innosoft.com"
    end
    def username
      'chris'
    end
    def has_password?
      true
    end
    def password
      'secret'
    end
  end
  preferences = MyDigestMD5Preferences.new

  it 'should authenticate (1)' do
    preferences.serv_type = 'imap'
    sasl = SASL::DigestMD5.new('DIGEST-MD5', preferences)
    sasl.start.should == ['auth', nil]
    sasl.cnonce = 'OA6MHXh6VqTrRk'
    response = sasl.receive('challenge',
                            'realm="elwood.innosoft.com",nonce="OA6MG9tEQGm2hh",qop="auth",
                             algorithm=md5-sess,charset=utf-8')
    response[0].should == 'response'
    response[1].should =~ /charset="?utf-8"?/
    response[1].should =~ /username="?chris"?/
    response[1].should =~ /realm="?elwood.innosoft.com"?/
    response[1].should =~ /nonce="?OA6MG9tEQGm2hh"?/
    response[1].should =~ /nc="?00000001"?/
    response[1].should =~ /cnonce="?OA6MHXh6VqTrRk"?/
    response[1].should =~ /digest-uri="?imap\/elwood.innosoft.com"?/
    response[1].should =~ /response=d388dad90d4bbd760a152321f2143af7"?/
    response[1].should =~ /"?qop=auth"?/

    sasl.receive('challenge',
                 'rspauth=ea40f60335c427b5527b84dbabcdfffd').should ==
      ['response', nil]
    sasl.receive('success', nil).should == nil
    sasl.success?.should == true
  end

  it 'should authenticate (2)' do
    preferences.serv_type = 'acap'
    sasl = SASL::DigestMD5.new('DIGEST-MD5', preferences)
    sasl.start.should == ['auth', nil]
    sasl.cnonce = 'OA9BSuZWMSpW8m'
    response = sasl.receive('challenge',
                            'realm="elwood.innosoft.com",nonce="OA9BSXrbuRhWay",qop="auth",
                             algorithm=md5-sess,charset=utf-8')
    response[0].should == 'response'
    response[1].should =~ /charset="?utf-8"?/
    response[1].should =~ /username="?chris"?/
    response[1].should =~ /realm="?elwood.innosoft.com"?/
    response[1].should =~ /nonce="?OA9BSXrbuRhWay"?/
    response[1].should =~ /nc="?00000001"?/
    response[1].should =~ /cnonce="?OA9BSuZWMSpW8m"?/
    response[1].should =~ /digest-uri="?acap\/elwood.innosoft.com"?/
    response[1].should =~ /response=6084c6db3fede7352c551284490fd0fc"?/
    response[1].should =~ /"?qop=auth"?/

    sasl.receive('challenge',
                 'rspauth=2f0b3d7c3c2e486600ef710726aa2eae').should ==
      ['response', nil]
    sasl.receive('success', nil).should == nil
    sasl.success?.should == true
  end

  it 'should reauthenticate' do
    preferences.serv_type = 'imap'
    sasl = SASL::DigestMD5.new('DIGEST-MD5', preferences)
    sasl.start.should == ['auth', nil]
    sasl.cnonce = 'OA6MHXh6VqTrRk'
    sasl.receive('challenge',
                 'realm="elwood.innosoft.com",nonce="OA6MG9tEQGm2hh",qop="auth",
                  algorithm=md5-sess,charset=utf-8')
    # reauth:
    response = sasl.start
    response[0].should == 'response'
    response[1].should =~ /charset="?utf-8"?/
    response[1].should =~ /username="?chris"?/
    response[1].should =~ /realm="?elwood.innosoft.com"?/
    response[1].should =~ /nonce="?OA6MG9tEQGm2hh"?/
    response[1].should =~ /nc="?00000002"?/
    response[1].should =~ /cnonce="?OA6MHXh6VqTrRk"?/
    response[1].should =~ /digest-uri="?imap\/elwood.innosoft.com"?/
    response[1].should =~ /response=b0b5d72a400655b8306e434566b10efb"?/ # my own result
    response[1].should =~ /"?qop=auth"?/
  end

  it 'should fail' do
    sasl = SASL::DigestMD5.new('DIGEST-MD5', preferences)
    sasl.start.should == ['auth', nil]
    sasl.receive('failure', 'EPIC FAIL')
    sasl.failure?.should == true
    sasl.success?.should == false
  end
end
