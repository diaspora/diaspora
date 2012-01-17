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
      AppConfig[:admins] = [alice.username]
      get :public
      response.should be_success
    end

    it 'will redirect if not' do
      AppConfig[:admins] = []
      get :public
      response.should be_redirect
    end
  end

  describe '#multi' do
    before do
      @old_spotlight_value = AppConfig[:community_spotlight]
    end

    after do
      AppConfig[:community_spotlight] = @old_spotlight_value
    end

    it 'succeeds' do
      AppConfig[:community_spotlight] = [bob.person.diaspora_handle]
      get :multi
      response.should be_success
    end

    it 'succeeds without AppConfig[:community_spotlight]' do
      AppConfig[:community_spotlight] = nil
      get :multi
      response.should be_success
    end

    it 'succeeds on mobile' do
      get :multi, :format => :mobile
      response.should be_success
    end
  end

  streams = [
    {:path => :liked, :type => Stream::Likes},
    {:path => :mentioned, :type => Stream::Mention},
    {:path => :followed_tags, :type => Stream::FollowedTag}
  ]

  streams.each do |s|
    describe "##{s[:path]}" do
      it 'succeeds' do
        get s[:path]
        response.should be_success
      end

      it 'assigns a stream' do
        get s[:path]
        assigns[:stream].should be_a s[:type]
      end
    end
  end
end
