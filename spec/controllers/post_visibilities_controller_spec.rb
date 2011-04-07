#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostVisibilitiesController do
  render_views

  before do
    a2 = bob.aspects.create(:name => "two")
    bob.contacts.create(:person => alice.person, :aspects => [a2])
   
    @status = bob.post(:status_message, :text => "hello", :to => a2)
    @vis = @status.post_visibilities.first
  end

  describe '#update' do
    before do
      sign_in :user, alice
    end

    context "on a post you can see" do
      it 'succeeds' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        response.should be_success
      end

      it 'marks hidden if visible' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        @vis.reload.hidden.should be_true
      end

      it 'marks visible if hidden' do
        @vis.update_attributes(:hidden => true)

        put :update, :format => :js, :id => 42, :post_id => @status.id
        @vis.reload.hidden.should be_false
      end
    end

    context "post you do not see" do
      before do
        sign_in :user, eve
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
