#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamsController do
  before do
    sign_in alice
  end

  describe "#public" do
    it 'will succeed if admin' do
      Role.add_admin(alice.person)
      get :public
      response.should be_success
    end

    it 'will redirect if not' do
      get :public
      response.should be_redirect
    end
  end

  describe '#multi' do
    it 'succeeds' do
      get :multi
      response.should be_success
    end

    it 'succeeds on mobile' do
      get :multi, :format => :mobile
      response.should be_success
    end
  end

  streams = {
      :liked => Stream::Likes,
      :mentioned => Stream::Mention,
      :followed_tags => Stream::FollowedTag,
      :activity => Stream::Activity
  }

  streams.each do |stream_path, stream_class|
    describe "a GET to #{stream_path}" do
      it 'assigns a stream of the proper class' do
        get stream_path
        response.should be_success
        assigns[:stream].should be_a stream_class
      end
    end
  end
end
