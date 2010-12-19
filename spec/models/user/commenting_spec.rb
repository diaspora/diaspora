#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user1){Factory.create(:user)}
  let!(:user2){Factory.create(:user)}
  let!(:aspect1){user1.aspects.create(:name => 'heroes')}
  let!(:aspect2){user2.aspects.create(:name => 'others')}

  before do
    connect_users(user1, aspect1, user2, aspect2)
    @post = user1.build_post(:status_message, :message => "hey", :to => aspect1.id)
    @post.save
    user1.dispatch_post(@post, :to => "all")
  end

  describe '#dispatch_comment' do
    context "post owner's contact is commenting" do
      it "doesn't call receive on local users" do
        user1.should_not_receive(:receive_comment)
        user2.should_not_receive(:receive_comment)
        
        comment = user2.build_comment "why so formal?", :on => @post
        comment.save!
        user2.dispatch_comment comment
      end
    end

    context "post owner is commenting on own post" do
      it "doesn't call receive on local users" do
        user1.should_not_receive(:receive_comment)
        user2.should_not_receive(:receive_comment)
        
        comment = user1.build_comment "why so formal?", :on => @post
        comment.save!
        user1.dispatch_comment comment
      end
    end
  end
end
