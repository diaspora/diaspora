#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe PublicsController do
  render_views
  let(:user) { make_user }
  let(:person){Factory(:person)}

  describe '#receive' do
    let(:xml) { "<walruses></walruses>" }
     context 'success cases' do
      it 'should 200 on successful receipt of a request, and queues a job' do
        Resque.should_receive(:enqueue).with(Jobs::ReceiveSalmon, user.id, xml).once
        post :receive, :id =>user.person.id, :xml => xml
        response.code.should == '200'
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
end
