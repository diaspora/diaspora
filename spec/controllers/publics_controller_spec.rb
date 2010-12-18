#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController do
  render_views

  let(:user)   { make_user }
  let(:person) { Factory(:person) }

  describe '#receive' do
    let(:xml) { "<walruses></walruses>" }

    it 'succeeds' do
      post :receive, "id" => user.person.id.to_s, "xml" => xml
      response.should be_success
    end

    it 'enqueues a receive job' do
      Resque.should_receive(:enqueue).with(Jobs::ReceiveSalmon, user.id, xml).once
      post :receive, "id" => user.person.id.to_s, "xml" => xml
    end

    it 'returns a 422 if no xml is passed' do
      post :receive, "id" => person.id.to_s
      response.code.should == '422'
    end

    it 'returns a 404 if no user is found' do
      post :receive, "id" => person.id.to_s, "xml" => xml
      response.should be_not_found
    end
  end

  describe '#hcard' do
    it "succeeds" do
      post :hcard, "id" => user.person.id.to_s
      response.should be_success
    end

    it 'sets the person' do
      post :hcard, "id" => user.person.id.to_s
      assigns[:person].should == user.person
    end

    it 'does not query by user id' do
      post :hcard, "id" => user.id.to_s
      assigns[:person].should be_nil
      response.should be_not_found
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
