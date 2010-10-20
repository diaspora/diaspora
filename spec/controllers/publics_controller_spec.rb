#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController do
  render_views
  let(:user) {Factory.create :user}
  let(:user2){Factory.create :user}
  let(:aspect1){user.aspect(:name => "foo")}
  let(:aspect2){user2.aspect(:name => "far")}
  before do
    sign_in :user, user
  end

  describe 'receive endpoint' do
    it 'should have a and endpoint and return a 200 on successful receipt of a request' do
      post :receive, :id =>user.person.id
      response.code.should == '200'
    end

    it 'should accept a post from another node and save the information' do
      message = user2.build_post(:status_message, :message => "hi")
      friend_users(user, aspect1, user2, aspect2)
      
      user.reload
      user.visible_post_ids.include?(message.id).should be false

      xml = user2.salmon(message).xml_for(user.person)

      post :receive, :id => user.person.id, :xml => xml

      user.reload
      user.visible_post_ids.include?(message.id).should be true
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

  describe 'webfinger' do
    it "succeeds when the person and user exist locally" do
      user = Factory(:user)
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

  describe 'friend requests' do
    let(:aspect2) {user2.aspect(:name => 'disciples')}
    let!(:req)     {user2.send_friend_request_to(user.person, aspect2)}
    let!(:xml)     {user2.salmon(req).xml_for(user.person)}
    before do
      req.delete
      user2.reload
      user2.pending_requests.count.should be 1
    end

    it 'should add the pending request to the right user if the target person exists locally' do
      user2.delete
      post :receive, :id => user.person.id, :xml => xml

      assigns(:user).should eq(user)
    end

    it 'should add the pending request to the right user if the target person does not exist locally' do
      Person.should_receive(:by_webfinger).with(user2.person.diaspora_handle).and_return(user2.person)
      user2.person.delete
      user2.delete
      post :receive, :id => user.person.id, :xml => xml

      assigns(:user).should eq(user)
    end
  end
end
