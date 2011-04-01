#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostVisibilitiesController do
  render_views

  before do
    @user1 = alice
    @bob = bob
    sign_in :user, @user1

    a2 = bob.aspects.create(:name => "two")
    a2.contacts << bob.contact_for(alice.person)
    a2.save

   
    @status = bob.post(:status_message, :text => "hello", :public => true, :to => a2)
    @vis = @status.post_visibilities.first
    @vis.reload.hidden.should == false
  end

  describe '#update' do
    context "on a post you can see" do
      it 'succeeds' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        response.should be_success
      end

      it 'marks hidden if visible' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        @vis.reload.hidden.should == true
      end

      it 'marks visible if hidden' do
        @vis.hidden = true
        @vis.save!
        put :update, :format => :js, :id => 42, :post_id => @status.id
        @vis.reload.hidden.should == false
      end
    end

    context "post you do not see" do
      before do
        user2 = eve
        sign_in :user, user2
      end
      it 'does not let a user destroy a visibility that is not theirs' do
        lambda {
          put :update, :format => :js, :id => 42, :post_id => @status.id
        }.should_not change(@vis.reload, :hidden).to(true)
      end
      it 'does not succceed' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        response.should_not be_success
      end
    end
  end
end
