#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagsController, :type => :controller do
  describe '#index (search)' do
    before do
      sign_in :user, alice
      bob.profile.tag_string = "#cats #diaspora #rad"
      bob.profile.build_tags
      bob.profile.save!
    end

    it 'responds with json' do
      get :index, :q => "ra", :format => 'json'
      #parse json
      expect(response.body).to include("#rad")
    end

    it 'requires at least two characters' do
      get :index, :q => "c", :format => 'json'
      expect(response.body).not_to include("#cats")
    end

    it 'redirects the aimless to excellent parties' do
      get :index
      expect(response).to redirect_to tag_path('partytimeexcellent')
    end

    it 'does not allow json requestors to party' do
      get :index, :format => :json
      expect(response.status).to eq(422)
    end
  end

  describe '#show' do
    context 'tag with capital letters' do
      before do
        sign_in :user, alice
      end

      it 'redirect to the downcase tag uri' do
        get :show, :name => 'DiasporaRocks!'
        expect(response).to redirect_to(:action => :show, :name => 'diasporarocks!')
      end
    end

    context 'with a tagged user' do
      before do
        bob.profile.tag_string = "#cats #diaspora #rad"
        bob.profile.build_tags
        bob.profile.save!
      end

      it 'includes the tagged user' do
        get :show, :name => 'cats'
        expect(response.body).to include(bob.diaspora_handle)
      end
    end

    context 'with a tagged post' do
      before do
        @post = eve.post(:status_message, text: "#what #yes #hellyes #foo tagged post", public: true, to: 'all')
      end

      context 'signed in' do
        before do
          sign_in :user, alice
        end

        it 'assigns a Stream::Tag object with the current_user' do
          get :show, :name => 'yes'
          expect(assigns[:stream].user).to eq(alice)
        end

        it 'succeeds' do
          get :show, :name => 'hellyes'
          expect(response.status).to eq(200)
        end

        it 'includes the tagged post' do
          get :show, :name => 'foo'
          expect(assigns[:stream].posts.first.text).to include("tagged post")
        end

        it 'includes comments of the tagged post' do
          alice.comment!(@post, "comment on a tagged post")
          get :show, :name => 'foo', :format => 'json'
          expect(response.body).to include("comment on a tagged post")
        end
      end

      context "not signed in" do
        it 'assigns a Stream::Tag object with no user' do
          get :show, :name => 'yes'
          expect(assigns[:stream].user).to be_nil
        end

        it 'succeeds' do
          get :show, :name => 'hellyes'
          expect(response.status).to eq(200)
        end

        it 'succeeds with mobile' do
          get :show, :name => 'foo', :format => :mobile
          expect(response).to be_success
        end
      end
    end
  end

  context 'helper methods' do
    describe 'tag_followed?' do
      before do
        sign_in bob
        @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
        allow(@controller).to receive(:current_user).and_return(bob)
        allow(@controller).to receive(:params).and_return({:name => "PARTYTIMEexcellent"})
      end

      it 'returns true if the following already exists and should be case insensitive' do
        TagFollowing.create!(:tag => @tag, :user => bob )
        expect(@controller.send(:tag_followed?)).to be true
      end

      it 'returns false if the following does not already exist' do
        expect(@controller.send(:tag_followed?)).to be false
      end
    end
  end
end
