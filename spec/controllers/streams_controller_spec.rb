# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe StreamsController, :type => :controller do
  include_context :gon

  before do
    sign_in alice
  end

  describe "#public" do
    it "succeeds" do
      get :public
      expect(response).to be_success
    end
  end

  describe '#multi' do
    it 'succeeds' do
      get :multi
      expect(response).to be_success
    end

    it 'succeeds on mobile' do
      get :multi, :format => :mobile
      expect(response).to be_success
    end

    context "getting started" do
      it "add the inviter to gon" do
        user = FactoryGirl.create(:user, getting_started: true, invited_by: alice)
        sign_in user

        get :multi

        expect(gon["preloads"][:mentioned_person][:name]).to eq(alice.person.name)
        expect(gon["preloads"][:mentioned_person][:handle]).to eq(alice.person.diaspora_handle)
      end
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
        expect(response).to be_success
        expect(assigns[:stream]).to be_a stream_class
      end
    end
  end
end
