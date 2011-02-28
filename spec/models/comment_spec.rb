#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  before do
    @alices_aspect = alice.aspects.first
    @bobs_aspect = bob.aspects.first

    @bob = bob
    @eve = eve
    @status = alice.post(:status_message, :message => "hello", :to => @alices_aspect.id)
  end

  describe 'comment#notification_type' do
    it "returns 'comment_on_post' if the comment is on a post you own" do
      comment = bob.comment("why so formal?", :on => @status)
      comment.notification_type(alice, bob.person).should == Notifications::CommentOnPost
    end

    it 'returns false if the comment is not on a post you own and no one "also_commented"' do
      comment = alice.comment("I simply felt like issuing a greeting.  Do step off.", :on => @status)
      comment.notification_type(@bob, alice.person).should == false
    end

    context "also commented" do
      before do
        @bob.comment("a-commenta commenta", :on => @status)
        @comment = @eve.comment("I also commented on the first user's post", :on => @status)
      end

      it 'does not return also commented if the user commented' do
        @comment.notification_type(@eve, alice.person).should == false
      end

      it "returns 'also_commented' if another person commented on a post you commented on" do
        @comment.notification_type(@bob, alice.person).should == Notifications::AlsoCommented
      end
    end
  end


  describe 'User#comment' do
    it "should be able to comment on one's own status" do
      alice.comment("Yeah, it was great", :on => @status)
      @status.reload.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a contact's status" do
      bob.comment("sup dog", :on => @status)
      @status.reload.comments.first.text.should == "sup dog"
    end
    it 'does not multi-post a comment' do
      lambda {
        alice.comment 'hello', :on => @status
      }.should change { Comment.count }.by(1)
    end
  end

  describe 'xml' do
    before do
      @commenter = Factory.create(:user)
      @commenter_aspect = @commenter.aspects.create(:name => "bruisers")
      connect_users(alice, @alices_aspect, @commenter, @commenter_aspect)
      @post = alice.post :status_message, :message => "hello", :to => @alices_aspect.id
      @comment = @commenter.comment "Fool!", :on => @post
      @xml = @comment.to_xml.to_s
    end
    it 'serializes the sender handle' do
      @xml.include?(@commenter.diaspora_handle).should be_true
    end
    it 'serializes the post_guid' do
      @xml.should include(@post.guid)
    end
    describe 'marshalling' do
      before do
        @marshalled_comment = Comment.from_xml(@xml)
      end
      it 'marshals the author' do
        @marshalled_comment.person.should == @commenter.person
      end
      it 'marshals the post' do
        @marshalled_comment.post.should == @post
      end
    end
  end

  describe 'youtube' do
    before do
      @message = alice.post :status_message, :message => "hi", :to => @alices_aspect.id
    end
    it 'should process youtube titles on the way in' do
      video_id = "ABYnqp-bxvg"
      url="http://www.youtube.com/watch?v=#{video_id}&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
      expected_title = "UP & down & UP & down &amp;"

      mock_http = mock("http")
      Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
      mock_http.should_receive(:get).with('/feeds/api/videos/'+video_id+'?v=2', nil).and_return(
        [nil, 'Foobar <title>'+expected_title+'</title> hallo welt <asd><dasdd><a>dsd</a>'])

      comment = alice.build_comment url, :on => @message

      comment.save!
      Comment.find(comment.id).youtube_titles.should == {video_id => CGI::escape(expected_title)}
    end
  end

  context 'comment propagation' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @person_status = Factory.create(:status_message, :person => @remote_raphael)
      @user_status = @local_luke.post :status_message, :message => "hi", :to => @local_luke.aspects.first
      @lukes_aspect = @local_luke.aspects.first
    end

    it 'should not clear the aspect post array on receiving a comment' do
      @lukes_aspect.post_ids.include?(@user_status.id).should be_true
      comment = Comment.new(:person_id => @remote_raphael.id, :text => "cats", :post => @user_status)

      zord = Postzord::Receiver.new(alice, :person => @remote_raphael)
      zord.parse_and_receive(comment.to_diaspora_xml)

      @lukes_aspect.reload
      @lukes_aspect.post_ids.include?(@user_status.id).should be_true
    end

    describe '#receive' do
      before do
        @comment = @local_luke.comment("yo", :on => @user_status)
        @comment2 = @local_leia.build_comment("yo", :on => @user_status)
        @new_c = @comment.dup
      end

      it 'does not overwrite a comment that is already in the db' do
        lambda{
          @new_c.receive(@local_leia, @local_luke.person)
        }.should_not change(Comment, :count)
      end

      it 'does not process if post_creator_signature is invalid' do
        @comment.delete # remove comment from db so we set a creator sig
        @new_c.parent_author_signature = "dsfadsfdsa"
        @new_c.receive(@local_leia, @local_luke.person).should == nil
      end

      it 'signs when the person receiving is the parent author' do
        @comment2.save
        @comment2.receive(@local_luke, @local_leia.person)
        @comment2.reload.parent_author_signature.should_not be_blank
      end

      it 'dispatches when the person receiving is the parent author' do
        p = Postzord::Dispatch.new(@local_luke, @comment2)
        p.should_receive(:post)
        Postzord::Dispatch.stub!(:new).and_return(p)
        @comment2.receive(@local_luke, @local_leia.person)
      end

      it 'sockets to the user' do
        @comment2.should_receive(:socket_to_user).exactly(3).times
        @comment2.receive(@local_luke, @local_leia.person)
      end
    end

    describe '#subscribers' do
      it 'returns the posts original audience, if the post is owned by the user' do
        comment = @local_luke.build_comment "yo", :on => @user_status
        comment.subscribers(@local_luke).map(&:id).should =~ [@local_leia.person, @remote_raphael].map(&:id)
      end

      it 'returns the owner of the original post, if the user owns the comment' do
        comment = @local_leia.build_comment "yo", :on => @user_status
        comment.subscribers(@local_leia).map(&:id).should =~ [@local_luke.person].map(&:id)
      end
    end
  end
end
