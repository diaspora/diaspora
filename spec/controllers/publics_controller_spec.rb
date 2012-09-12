#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController do
  let(:fixture_path) { Rails.root.join('spec', 'fixtures') }
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
  end

  describe '#host_meta' do
    it 'succeeds', :fixture => true do
      get :host_meta
      response.should be_success
      response.body.should =~ /webfinger/
      save_fixture(response.body, "host-meta", fixture_path)
    end
  end

  describe '#receive_public' do
    it 'succeeds' do
      post :receive_public, :xml => "<stuff/>"
      response.should be_success
    end

    it 'returns a 422 if no xml is passed' do
      post :receive_public
      response.code.should == '422'
    end

    it 'enqueues a ReceiveUnencryptedSalmon job' do
      xml = "stuff"
      Resque.should_receive(:enqueue).with(Jobs::ReceiveUnencryptedSalmon, xml)
      post :receive_public, :xml => xml
    end
  end

  describe '#receive' do
    let(:xml) { "<walruses></walruses>" }

    it 'succeeds' do
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
      response.should be_success
    end

    it 'enqueues a receive job' do
      Resque.should_receive(:enqueue).with(Jobs::ReceiveEncryptedSalmon, @user.id, xml).once
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
    end

    it 'unescapes the xml before sending it to receive_salmon' do
      aspect = @user.aspects.create(:name => 'foo')
      post1 = @user.post(:status_message, :text => 'moms', :to => [aspect.id])
      xml2 = post1.to_diaspora_xml
      user2 = FactoryGirl.create(:user)

      salmon_factory = Salmon::EncryptedSlap.create_by_user_and_activity(@user, xml2)
      enc_xml = salmon_factory.xml_for(user2.person)

      Resque.should_receive(:enqueue).with(Jobs::ReceiveEncryptedSalmon, @user.id, enc_xml).once
      post :receive, "guid" => @user.person.guid.to_s, "xml" => CGI::escape(enc_xml)
    end

    it 'returns a 422 if no xml is passed' do
      post :receive, "guid" => @person.guid.to_s
      response.code.should == '422'
    end

    it 'returns a 404 if no user is found' do
      post :receive, "guid" => @person.guid.to_s, "xml" => xml
      response.should be_not_found
    end
    it 'returns a 404 if no person is found' do
      post :receive, :guid => '2398rq3948yftn', :xml => xml
      response.should be_not_found
    end
  end

  describe '#hcard' do
    it "succeeds", :fixture => true do
      post :hcard, "guid" => @user.person.guid.to_s
      response.should be_success
      save_fixture(response.body, "hcard", fixture_path)
    end

    it 'sets the person' do
      post :hcard, "guid" => @user.person.guid.to_s
      assigns[:person].should == @user.person
    end

    it 'does not query by user id' do
      post :hcard, "guid" => 90348257609247856.to_s
      assigns[:person].should be_nil
      response.should be_not_found
    end

    it 'finds nothing for closed accounts' do
      @user.person.update_attributes(:closed_account => true)
      get :hcard, :guid => @user.person.guid.to_s
      response.should be_not_found
    end
  end

  describe '#webfinger' do
    it "succeeds when the person and user exist locally", :fixture => true do
      post :webfinger, 'q' => @user.person.diaspora_handle
      response.should be_success
      save_fixture(response.body, "webfinger", fixture_path)
    end

    it "404s when the person exists remotely because it is local only" do
      stub_success('me@mydiaspora.pod.com')
      post :webfinger, 'q' => 'me@mydiaspora.pod.com'
      response.should be_not_found
    end

    it "404s when the person is local but doesn't have an owner" do
      post :webfinger, 'q' => @person.diaspora_handle
      response.should be_not_found
    end

    it "404s when the person does not exist locally or remotely" do
      stub_failure('me@mydiaspora.pod.com')
      post :webfinger, 'q' => 'me@mydiaspora.pod.com'
      response.should be_not_found
    end

    it 'has the users profile href' do
      get :webfinger, :q => @user.diaspora_handle
      response.body.should include "http://webfinger.net/rel/profile-page"
    end

    it 'finds nothing for closed accounts' do
      @user.person.update_attributes(:closed_account => true)
      get :webfinger, :q => @user.diaspora_handle
      response.should be_not_found
    end
  end

  describe '#hub' do
    it 'succeeds' do
      get :hub
      response.should be_success
    end
  end
end
