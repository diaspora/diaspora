#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AuthorizationsController do
  RSA = OpenSSL::PKey::RSA

  before :all do
    @private_key = RSA.generate(2048)
    @public_key = @private_key.public_key
  end

  before do
    sign_in :user, alice 
    @controller.stub(:current_user).and_return(alice)

    @time = Time.now
    Time.stub(:now).and_return(@time)
    @nonce = 'asdfsfasf'
    @signable_string = ["http://chubbi.es/",'http://pod.pod/',"#{Time.now.to_i}", @nonce].join(';')
  end

  describe '#token' do
    before do
      manifest =   {
        "name"         => "Chubbies",
        "description"  => "The best way to chub.",
        "homepage_url" => "http://chubbi.es/",
        "icon_url"     => "#",
        "permissions_overview"     => "I will use the permissions this way!",
      }

      packaged_manifest = {:public_key => @public_key.export, :jwt => JWT.encode(manifest, @private_key, "RS256")}.to_json

      stub_request(:get, "http://chubbi.es/manifest.json"). 
        to_return(:status => 200, :body =>  packaged_manifest, :headers => {})

      @params_hash = {:type => 'client_associate', :manifest_url => "http://chubbi.es/manifest.json" }
    end

    it 'fetches the manifest' do
      @controller.stub!(:verify).and_return('ok')
      post :token,  @params_hash
    end
    
    it 'creates a client application' do
      @controller.stub!(:verify).and_return('ok')
      lambda {
        post :token,  @params_hash
      }.should change(OAuth2::Provider.client_class, :count).by(1)
    end

    it 'does not create a client if verification fails' do
      @controller.stub!(:verify).and_return('invalid signature')
      lambda {
        post :token,  @params_hash
      }.should_not change(OAuth2::Provider.client_class, :count)
    end
    
    it 'verifies the signable string validity(time,nonce,sig)' do
      @controller.should_receive(:verify){|a,b,c| 
        a.should == 'signed_string'
        b.should == 'sig'
        c.export.should == @public_key.export 
      }
      post :token,  @params_hash.merge!({:signed_string => 'signed_string', :signature => 'sig'})
    end
  end

  describe "#index" do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'assigns the auth. & apps for the current user' do
     app1 = OAuth2::Provider.client_class.create(:name => "Authorized App") 
     app2 = OAuth2::Provider.client_class.create(:name => "Unauthorized App") 
     auth1 = OAuth2::Provider.authorization_class.create(:client => app1, :resource_owner => alice)
     auth2 = OAuth2::Provider.authorization_class.create(:client => app1, :resource_owner => bob)
     auth3 = OAuth2::Provider.authorization_class.create(:client => app2, :resource_owner => bob)

     get :index
     assigns[:authorizations].should == [auth1]
     assigns[:applications].should == [app1]
    end
  end

  describe "#destroy" do
    before do
     @app1 = OAuth2::Provider.client_class.create(:name => "Authorized App") 
     @auth1 = OAuth2::Provider.authorization_class.create(:client => @app1, :resource_owner => alice)
     @auth2 = OAuth2::Provider.authorization_class.create(:client => @app1, :resource_owner => bob)
    end
    it 'deletes an authorization' do
      lambda{
        delete :destroy, :id => @app1.id 
      }.should change(OAuth2::Provider.authorization_class, :count).by(-1)
    end
  end

  describe '#verify' do
    before do
      @controller.stub!(:verify_signature)
      @sig = Base64.encode64('sig')
    end
    it 'checks for valid time' do
      @controller.should_receive(:valid_time?).with(@time.to_i.to_s)
      @controller.verify(Base64.encode64(@signable_string), @sig, @public_key)
    end

    it 'checks the signature' do
      @controller.should_receive(:verify_signature).with(@signable_string, 'sig', @public_key)
      @controller.verify(Base64.encode64(@signable_string), @sig, @public_key)
    end

    it 'checks for valid nonce' do
      @controller.should_receive(:valid_nonce?).with(@nonce)
      @controller.verify(Base64.encode64(@signable_string), @sig, @public_key)
    end

    it 'checks for public key' do
      @controller.verify(Base64.encode64(@signable_string), @sig, RSA.new()).should == "blank public key"
    end
    
    it 'checks key size' do
      short_key = RSA.generate(100)
      RSA.stub!(:new).and_return(short_key)
      @controller.verify(Base64.encode64(@signable_string), @sig, RSA.generate(100).public_key).
        should == "key too small, use at least 2048 bits"
    end
  end

  describe '#verify_signature' do
    before do

      @sig = @private_key.sign(OpenSSL::Digest::SHA256.new, @signable_string)
    end

    it 'returns true if the signature is valid' do
      @controller.verify_signature(@signable_string, @sig, @public_key).should be_true
    end

    it 'returns false if the signature is invalid' do
      @signable_string = "something else"

      @controller.verify_signature(@signable_string, @sig, @public_key).should be_false
    end
  end

  describe "valid_time?" do


    it "returns true if time is within the last 5 minutes" do
       @controller.valid_time?(@time - 4.minutes - 59.seconds).should be_true
    end

    it "returns false if time is not within the last 5 minutes" do
       @controller.valid_time?(@time - 5.minutes - 1.seconds).should be_false
    end
  end

  describe 'valid_nonce' do
    before do
       @app1 = OAuth2::Provider.client_class.create(:name => "Authorized App", :nonce => "abc123") 
    end

    it 'returns true if its a new nonce' do
      @controller.valid_nonce?("lalalala").should be_true
    end
    
    it 'returns false if the nonce was already used' do
      @controller.valid_nonce?("abc123").should be_false
    end
  end
end
