#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
    @signed_string = ["http://chubbi.es/",'http://pod.pod',"#{Time.now.to_i}", @nonce].join(';')
    @signature = @private_key.sign(OpenSSL::Digest::SHA256.new, @signed_string)

    @manifest =   {
        "name"         => "Chubbies",
        "description"  => "The best way to chub.",
        "application_base_url" => "http://chubbi.es/",
        "icon_url"     => "#",
        "permissions_overview" => "I will use the permissions this way!",
      }
  end

  describe '#new' do
    before do
      @app = FactoryGirl.create(:app, :name => "Authorized App")
      @params = {
        :scope => "profile",
        :redirect_uri => @manifest['application_base_url'] << '/callback',
        :client_id => @app.oauth_identifier,
        :uid => alice.username
      }
    end
    it 'succeeds' do
      get :new, @params
      response.should be_success
    end

    it 'logs out the signed in user if a different username is passed' do
      @params[:uid] = bob.username
      get :new, @params
      response.location.should include(oauth_authorize_path)
    end

    it 'it succeeds if no uid is passed' do
      @params[:uid] = nil
      get :new, @params
      response.should be_success
    end
  end

  describe '#token' do
    before do
      packaged_manifest = {:public_key => @public_key.export, :jwt => JWT.encode(@manifest, @private_key, "RS256")}.to_json

      stub_request(:get, "http://chubbi.es/manifest.json").
        to_return(:status => 200, :body =>  packaged_manifest, :headers => {})

      @params_hash = {:type => 'client_associate', :signed_string => Base64.encode64(@signed_string), :signature => Base64.encode64(@signature)}
    end

    context 'special casing (temporary, read note in the controller)' do
      def prepare_manifest(url)
        manifest =   {
          "name"         => "Chubbies",
          "description"  => "The best way to chub.",
          "application_base_url" => url,
          "icon_url"     => "#",
          "permissions_overview" => "I will use the permissions this way!",
        }

        packaged_manifest = {:public_key => @public_key.export, :jwt => JWT.encode(manifest, @private_key, "RS256")}.to_json

        stub_request(:get, "#{url}manifest.json").
          to_return(:status => 200, :body =>  packaged_manifest, :headers => {})

        @signed_string = [url,'http://pod.pod',"#{Time.now.to_i}", @nonce].join(';')
        @signature = @private_key.sign(OpenSSL::Digest::SHA256.new, @signed_string)
        @params_hash = {:type => 'client_associate', :signed_string => Base64.encode64(@signed_string), :signature => Base64.encode64(@signature)}
      end

      it 'renders something for chubbies ' do
        prepare_manifest("http://chubbi.es/")
        @controller.stub!(:verify).and_return('ok')
        post :token,  @params_hash
        response.code.should == "200"
      end

      it 'renders something for cubbies ' do
        prepare_manifest("http://cubbi.es/")
        @controller.stub!(:verify).and_return('ok')
        post :token,  @params_hash
        response.code.should == "200"
      end

      it 'renders something for cubbies ' do
        prepare_manifest("https://www.cubbi.es:443/")
        @controller.stub!(:verify).and_return('ok')
        post :token,  @params_hash
        response.code.should == "200"
      end

      it 'renders something for localhost' do
        prepare_manifest("http://localhost:3423/")
        @controller.stub!(:verify).and_return('ok')
        post :token,  @params_hash
        response.code.should == "200"
      end

      it 'renders nothing for myspace' do
        prepare_manifest("http://myspace.com")
        @controller.stub!(:verify).and_return('ok')
        post :token,  @params_hash
        response.code.should == "403"
        response.body.should include("http://myspace.com")
      end
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
      @controller.should_receive(:verify){|a,b,c,d|
        a.should == @signed_string
        b.should == @signature
        c.export.should == @public_key.export
        d.should == @manifest
      }
      post :token,  @params_hash
    end
  end

  describe "#index" do
    it 'succeeds' do
      get :index
      response.should be_success
    end
    it 'succeeds on a phone' do
      get :index, :format => :mobile
      response.should be_success
    end

    it 'assigns the auth. & apps for the current user' do
     app1 = FactoryGirl.create(:app, :name => "Authorized App")
     app2 = FactoryGirl.create(:app, :name => "Unauthorized App")
     auth = OAuth2::Provider.authorization_class.create(:client => app1, :resource_owner => alice)

     OAuth2::Provider.authorization_class.create(:client => app1, :resource_owner => bob)
     OAuth2::Provider.authorization_class.create(:client => app2, :resource_owner => bob)

     get :index
     assigns[:authorizations].should == [auth]
     assigns[:applications].should == [app1]
    end
  end

  describe "#destroy" do
    before do
     @app1 = FactoryGirl.create(:app)
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
      @sig = 'sig'
    end
    it 'checks for valid time' do
      @controller.should_receive(:valid_time?).with(@time.to_i.to_s)
      @controller.verify(@signed_string, @sig, @public_key, @manifest)
    end

    it 'checks the signature' do
      @controller.should_receive(:verify_signature).with(@signed_string, 'sig', @public_key)
      @controller.verify(@signed_string, @sig, @public_key, @manifest)
    end

    it 'checks for valid nonce' do
      @controller.should_receive(:valid_nonce?).with(@nonce)
      @controller.verify(@signed_string, @sig, @public_key, @manifest)
    end

    it 'checks for public key' do
      @controller.verify(@signed_string, @sig, RSA.new(), @manifest).should == "blank public key"
    end

    it 'checks consistency of app_url' do
      @controller.verify(@signed_string, @sig, @public_key, @manifest.merge({"application_base_url" => "http://badsite.com/"})).
        should == "the app url in the manifest (http://badsite.com/) does not match the url passed in the parameters (http://chubbi.es/)."
    end

    it 'checks key size' do
      short_key = RSA.generate(100)
      RSA.stub!(:new).and_return(short_key)
      @controller.verify(@signed_string, @sig, RSA.generate(100).public_key, @manifest).
        should == "key too small, use at least 2048 bits"
    end
  end

  describe '#verify_signature' do
    before do

      @sig = @private_key.sign(OpenSSL::Digest::SHA256.new, @signed_string)
    end

    it 'returns true if the signature is valid' do
      @controller.verify_signature(@signed_string, @sig, @public_key).should be_true
    end

    it 'returns false if the signature is invalid' do
      @signed_string = "something else"

      @controller.verify_signature(@signed_string, @sig, @public_key).should be_false
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
      @nonce = "abc123"
      FactoryGirl.create(:app, :nonce => @nonce)
    end

    it 'returns true if its a new nonce' do
      @controller.valid_nonce?("lalalala").should be_true
    end

    it 'returns false if the nonce was already used' do
      @controller.valid_nonce?(@nonce).should be_false
    end
  end
end
