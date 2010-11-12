#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe PublicsController do
  render_views
  let!(:user) { make_user }
  let!(:user2) { make_user }
  let!(:aspect1) { user.aspects.create(:name => "foo") }
  let!(:aspect2) { user2.aspects.create(:name => "far") }
  let!(:aspect2) { user2.aspects.create(:name => 'disciples') }
  let!(:req) { user2.send_friend_request_to(user.person, aspect2) }
  let!(:xml) { user2.salmon(req).xml_for(user.person) }
  let(:person){Factory(:person)}

  before do
    sign_in :user, user

  end
  
  describe '#receive' do
    before do
      EventMachine::HttpRequest.stub!(:new).and_return(FakeHttpRequest.new(:success))
    end

    context 'success cases' do
      before do
        @person_mock = mock()
        @user_mock = mock()
        @user_mock.stub!(:receive_salmon).and_return(true)
        @person_mock.stub!(:owner_id).and_return(true)
        @person_mock.stub!(:owner).and_return(@user_mock)
        Person.stub!(:first).and_return(@person_mock)
      end
      it 'should 200 on successful receipt of a request' do
        post :receive, :id =>user.person.id, :xml => xml
        response.code.should == '200'
      end

      it 'should have the xml processed as salmon on success' do
        @user_mock.should_receive(:receive_salmon).and_return(true)
        post :receive, :id => user.person.id, :xml => xml
      end
    end

    it 'should return a 422 if no xml is passed' do
      post :receive, :id => person.id
      response.code.should == '422'
    end

    it 'should return a 404 if no user is found' do
      post :receive, :id => person.id, :xml => xml
      response.code.should == '404'
    end
  end


  describe '#hcard' do
    it 'queries by person id' do
      post :hcard, :id => user.person.id
      assigns[:person].should == user.person
      response.code.should == '200'
    end

    it 'does not query by user id' do
      post :hcard, :id => user.id
      assigns[:person].should be_nil
      response.code.should == '404'
    end
  end

  describe '#webfinger' do
    it "succeeds when the person and user exist locally" do
      user = make_user
      post :webfinger, 'q' => user.person.diaspora_handle
      response.should be_success
    end

    it "404s when the person exists remotely because it is local only" do
      stub_success('me@mydiaspora.pod.com')
      post :webfinger, 'q' => 'me@mydiaspora.pod.com'
      response.should be_not_found
    end

    it "404s when the person is local but doesn't have an owner" do
      person = Factory(:person)
      post :webfinger, 'q' => person.diaspora_handle
      response.should be_not_found
    end

    it "404s when the person does not exist locally or remotely" do
      stub_failure('me@mydiaspora.pod.com')
      post :webfinger, 'q' => 'me@mydiaspora.pod.com'
      response.should be_not_found
    end
  end

  context 'intergration tests that should not be in this file' do
    describe 'friend requests' do
      before do
        req.delete
        user2.reload
        user2.pending_requests.count.should be 1
      end

      it 'should accept a post from another node and save the information' do
        pending
        message = user2.build_post(:status_message, :message => "hi")

        connect_users(user, aspect1, user2, aspect2)

        user.reload
        user.visible_post_ids.include?(message.id).should be false

        xml1 = user2.salmon(message).xml_for(user.person)

        EM::run{
          post :receive, :id => user.person.id, :xml => xml1
          EM.stop
        }
        user.reload
        user.visible_post_ids.include?(message.id).should be true
      end
    end
  end
end
