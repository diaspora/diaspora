#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostVisibilitiesController do
  render_views

  before do
    @user1 = alice
    sign_in :user, @user1

   
    status = @user1.post(:status_message, :text => "hello", :public => true, :to => 'all')
    @vis = status.post_visibilities.first
    pp @vis
    @vis.reload.hidden.should == false
  end

  describe '#destroy' do
    it 'deletes the visibility' do
      delete :destroy, :conversation_id => @vis.id
      @vis.reload.hidden.should == true
    end

    it 'does not let a user destroy a visibility that is not theirs' do
      user2 = eve
      sign_in :user, user2

      lambda {
        delete :destroy, :conversation_id => @vis.id
      }.should_not change(@vis.reload, :hidden).to(true)
    end
  end
end
