#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ShareVisibilitiesController do
  before do
    @status = alice.post(:status_message, :text => "hello", :to => alice.aspects.first)
    sign_in :user, bob
  end

  describe '#update' do
    context "on a post you can see" do
      it 'succeeds' do
        put :update, :format => :js, :id => 42, :post_id => @status.id
        response.should be_success
      end

      it 'it calls toggle_hidden_shareable' do
        @controller.current_user.should_receive(:toggle_hidden_shareable).with(an_instance_of(Post))
        put :update, :format => :js, :id => 42, :post_id => @status.id
      end
    end
  end
 
  describe "#accessible_post" do
    it "memoizes a query for a post given a post_id param" do
      id = 1
      @controller.params[:post_id] = id
      @controller.params[:shareable_type] = 'Post'

      Post.should_receive(:where).with(hash_including(:id => id)).once.and_return(double.as_null_object)
      2.times do |n|
        @controller.send(:accessible_post)
      end
    end
  end
end
