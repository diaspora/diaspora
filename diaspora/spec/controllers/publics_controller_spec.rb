#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController do
  let(:fixture_path) { File.join(Rails.root, 'spec', 'fixtures')}
  before do
    @user = alice
    @person = Factory(:person)
  end

  describe '#host_meta' do
    it 'succeeds', :fixture => true do
      get :host_meta
      response.should be_success
      response.body.should =~ /webfinger/
      save_fixture(response.body, "host-meta", fixture_path)
    end
  end

  describe '#receive' do
    let(:xml) { "<walruses></walruses>" }

    it 'succeeds' do
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
      response.should be_success
    end

    it 'enqueues a receive job' do
      Resque.should_receive(:enqueue).with(Job::ReceiveSalmon, @user.id, xml).once
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
    end

    it 'unescapes the xml before sending it to receive_salmon' do
      aspect = @user.aspects.create(:name => 'foo')
      post1 = @user.post(:status_message, :text => 'moms', :to => [aspect.id])
      xml2 = post1.to_diaspora_xml
      user2 = Factory(:user)

      salmon_factory = Salmon::SalmonSlap.create(@user, xml2)
      enc_xml = salmon_factory.xml_for(user2.person)

      Resque.should_receive(:enqueue).with(Job::ReceiveSalmon, @user.id, enc_xml).once
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

  describe '#post' do
    it 'shows a public post' do
      status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')

      get :post, :guid => status.id
      response.status= 200
    end

    it 'does not show a private post' do
      status = alice.post(:status_message, :text => "hello", :public => false, :to => 'all')
      get :post, :guid => status.id
      response.status = 302
    end

    it 'redirects to the proper show page if the user has visibility of the post' do
      status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
      sign_in bob
      get :post, :guid => status.id
      response.should be_redirect
    end

    it 'responds with diaspora xml if format is xml' do
      status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
      get :post, :guid => status.guid, :format => :xml
      response.body.should == status.to_diaspora_xml
    end

    # We want to be using guids from now on for this post route, but do not want to break
    # preexisiting permalinks.  We can assume a guid is 8 characters long as we have
    # guids set to hex(8) since we started using them.
    context 'id/guid switch' do
      before do
        @status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
      end

      it 'assumes guids less than 8 chars are ids and not guids' do
        Post.should_receive(:where).with(hash_including(:id => @status.id)).and_return(Post)
        get :post, :guid => @status.id
        response.status= 200
      end

      it 'assumes guids more than (or equal to) 8 chars are actually guids' do
        Post.should_receive(:where).with(hash_including(:guid => @status.guid)).and_return(Post)
        get :post, :guid => @status.guid
        response.status= 200
      end
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
  end

  describe '#hub' do
    it 'succeeds' do
      get :hub
      response.should be_success
    end
  end
end
