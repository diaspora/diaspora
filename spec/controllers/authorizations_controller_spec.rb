#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AuthorizationsController do
  before do
    sign_in :user, alice 
    @controller.stub(:current_user).and_return(alice)

  end

  describe '#token' do
    before do
      manifest =   {
        "name"         => "Chubbies",
        "description"  => "The best way to chub.",
        "homepage_url" => "http://chubbi.es/",
        "icon_url"     => "#",
        'public_key'   => 'public_key!'
      }.to_json 

      stub_request(:get, "http://chubbi.es/manifest.json"). 
        to_return(:status => 200, :body =>  manifest, :headers => {})

      @params_hash = {:type => 'client_associate', :manifest_url => "http://chubbi.es/manifest.json" }
    end

    it 'fetches the manifest' do
      post :token,  @params_hash
    end
    
    it 'creates a client application' do
      lambda {
        post :token,  @params_hash
      }.should change(OAuth2::Provider.client_class, :count).by(1)
    end

    it 'verifies the signable string validity(time,nonce,sig)' do
      post :token,  @params_hash.merge!({:signed_string => 'signable_string', :signature => 'sig'})
      @controller.should_receive(:verify).with('signable_string', 'sig', 'public_key!')
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
    it 'checks for valid time'
    it 'checks the signature'
    it 'checks for valid nonce'
  end

  describe '#verify_signature' do
    before do
      @private_key = OpenSSL::PKey::RSA.new(File.read(Rails.root + "spec/chubbies/chubbies.private.pem"))

      @signable_string = ["http://chubbi.es/",'http://pod.pod/',"#{Time.now.to_i}",'asdfsfasf'].join(';')
      @sig = @private_key.sign(OpenSSL::Digest::SHA256.new, @signable_string)
    end

    it 'returns true if the signature is valid' do
      @public_key = File.read(Rails.root + "spec/chubbies/chubbies.public.pem")
      @controller.verify_signature(@signable_string, Base64.encode64(@sig), @public_key).should be_true
    end

    it 'returns false if the signature is invalid' do
      @signable_string = "something else"

      @public_key = File.read(Rails.root + "spec/chubbies/chubbies.public.pem")
      @controller.verify_signature(@signable_string, Base64.encode64(@sig), @public_key).should be_false
    end
  end

  describe "valid_time?" do
    before do
      @time = Time.now
      Time.stub(:now).and_return(@time)
    end

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
