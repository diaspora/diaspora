#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ParticipationsController do
  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first

    sign_in :user, alice
  end

  context "Posts" do
      let(:id_field){ "post_id" }

    describe '#create' do
      let(:participation_hash) {
        { id_field => "#{@target.id}",
          :format => :json}
      }
      let(:disparticipation_hash) {
        { id_field => "#{@target.id}",
          :format => :json }
      }

      context "on my own post" do
        it 'succeeds' do
          @target = alice.post :status_message, :text => "AWESOME", :to => @alices_aspect.id
          post :create, participation_hash
          response.code.should == '201'
        end
      end

      context "on a post from a contact" do
        before do
          @target = bob.post(:status_message, :text => "AWESOME", :to => @bobs_aspect.id)
        end

        it 'participations' do
          post :create, participation_hash
          response.code.should == '201'
        end

        it 'disparticipations' do
          post :create, disparticipation_hash
          response.code.should == '201'
        end

        it "doesn't post multiple times" do
          alice.participate!(@target)
          post :create, disparticipation_hash
          response.code.should == '422'
        end
      end

      context "on a post from a stranger" do
        before do
          @target = eve.post :status_message, :text => "AWESOME", :to => eve.aspects.first.id
        end

        it "doesn't post" do
          alice.should_not_receive(:participate!)
          post :create, participation_hash
          response.code.should == '422'
        end
      end
    end

    describe '#index' do
      before do
        @message = alice.post(:status_message, :text => "hey", :to => @alices_aspect.id)
      end

      it 'generates a jasmine fixture', :fixture => true do
        get :index, id_field => @message.id, :format => :json

        save_fixture(response.body, "ajax_participations_on_posts")
      end

      it 'returns a 404 for a post not visible to the user' do
        sign_in eve
        get :index, id_field => @message.id, :format => :json
      end

      it 'returns an array of participations for a post' do
        bob.participate!(@message)
        get :index, id_field => @message.id, :format => :json
        assigns[:participations].map(&:id).should == @message.participation_ids
      end

      it 'returns an empty array for a post with no participations' do
        get :index, id_field => @message.id, :format => :json
        assigns[:participations].should == []
      end
    end

    describe '#destroy' do
      before do
        @message = bob.post(:status_message, :text => "hey", :to => @alices_aspect.id)
        @participation = alice.participate!(@message)
      end

      it 'lets a user destroy their participation' do
        expect {
          delete :destroy, :format => :json, id_field => @participation.target_id, :id => @participation.id
        }.should change(Participation, :count).by(-1)
        response.status.should == 202
      end

      it 'does not let a user destroy other participations' do
        participation2 = eve.participate!(@message)

        expect {
          delete :destroy, :format => :json, id_field => participation2.target_id, :id => participation2.id
        }.should_not change(Participation, :count)

        response.status.should == 403
      end
    end
  end
end
