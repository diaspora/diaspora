#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user1){make_user}
  let!(:user2){make_user}
  let!(:aspect1){user1.aspects.create(:name => 'heroes')}
  let!(:aspect2){user2.aspects.create(:name => 'others')}

  before do
    connect_users(user1, aspect1, user2, aspect2)
    @post = user1.build_post(:status_message, :message => "hey", :to => aspect1.id)
    @post.save
    user1.dispatch_post(@post, :to => "all")
  end

  describe '#dispatch_comment' do

    context 'post owners contact comments on post' do
      it 'should not call receive on local users' do
        pending 'need to call should_receive without it being destructive'

        user1.should_receive(:receive_comment)
        user2.should_not_receive(:receive_comment)
        user1.should_receive(:dispatch_comment)

        user1.reload
        user2.reload

        comment = user2.build_comment "why so formal?", :on => @post
        comment.save!
        user2.dispatch_comment comment
      end
    end

    context 'post owner comments on own post' do
      it 'should only dispatch once' do
        pending 'need to call should_receive without it being destructive'

        user1.should_receive(:dispatch_comment).once
        user2.should_not_receive(:receive_comment)
        user2.should_not_receive(:dispatch_comment)

        user1.reload
        user2.reload

        comment = user1.build_comment "why so serious?", :on => @post
        comment.save
        user1.dispatch_comment comment
      end
    end

  end
end
