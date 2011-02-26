#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  before do
    @alices_aspect = alice.aspects.first
    @bobs_aspect = bob.aspects.first
  end

  describe 'comment#notification_type' do
    before do
      @sam = Factory(:user_with_aspect)
      connect_users(alice, @alices_aspect, @sam, @sam.aspects.first)

      @alices_post = alice.post(:status_message, :message => "hello", :to => @alices_aspect.id)
    end

    it "returns 'comment_on_post' if the comment is on a post you own" do
      comment = bob.comment("why so formal?", :on => @alices_post)
      comment.notification_type(alice, bob.person).should == 'comment_on_post'
    end

    it 'returns false if the comment is not on a post you own and no one "also_commented"' do
      comment = alice.comment("I simply felt like issuing a greeting.  Do step off.", :on => @alices_post)
      comment.notification_type(@sam, alice.person).should == false
    end

    context "also commented" do
      before do
        bob.comment("a-commenta commenta", :on => @alices_post)
        @comment = @sam.comment("I also commented on the first user's post", :on => @alices_post)
      end

      it 'does not return also commented if the user commented' do
        @comment.notification_type(@sam, alice.person).should == false
      end

      it "returns 'also_commented' if another person commented on a post you commented on" do
        @comment.notification_type(bob, alice.person).should == 'also_commented'
      end
    end
  end


  describe 'User#comment' do
    before do
      @status = alice.post(:status_message, :message => "hello", :to => @alices_aspect.id)
    end

    it "should be able to comment on one's own status" do
      alice.comment("Yeah, it was great", :on => @status)
      @status.reload.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a contact's status" do
      bob.comment("sup dog", :on => @status)
      @status.reload.comments.first.text.should == "sup dog"
    end
  end

  context 'comment propagation' do
    before do
      @person = Factory.create(:person)
      alice.activate_contact(@person, @alices_aspect)

      @person2 = Factory.create(:person)
      @person3 = Factory.create(:person)
      alice.activate_contact(@person3, @alices_aspect)

      @person_status = Factory.create(:status_message, :person => @person)

      alice.reload
      @user_status = alice.post :status_message, :message => "hi", :to => @alices_aspect.id

      @alices_aspect.reload
      alice.reload
    end

    it 'should send the comment to the postman' do
      m = mock()
      m.stub!(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)
      alice.comment "yo", :on => @person_status
    end

    describe '#subscribers' do
      it 'returns the posts original audience, if the post is owned by the user' do
        comment = alice.build_comment "yo", :on => @person_status
        comment.subscribers(alice).should =~ [@person]
      end

      it 'returns the owner of the original post, if the user owns the comment' do
        comment = alice.build_comment "yo", :on => @user_status
        comment.subscribers(alice).map { |s| s.id }.should =~ [@person, @person3, bob.person].map { |s| s.id }
      end
    end

    context 'testing a method only used for testing' do
      it "should send a user's comment on a person's post to that person" do
        m = mock()
        m.stub!(:post)
        Postzord::Dispatch.should_receive(:new).and_return(m)

        alice.comment "yo", :on => @person_status
      end
    end

    it 'should not clear the aspect post array on receiving a comment' do
      @alices_aspect.post_ids.include?(@user_status.id).should be_true
      comment = Comment.new(:person_id => @person.id, :text => "cats", :post => @user_status)

      zord = Postzord::Receiver.new(alice, :person => @person)
      zord.parse_and_receive(comment.to_diaspora_xml)

      @alices_aspect.reload
      @alices_aspect.post_ids.include?(@user_status.id).should be_true
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
  describe 'local commenting' do
    before do
      @status = alice.post(:status_message, :message => "hello", :to => @alices_aspect.id)
    end
    it 'does not multi-post a comment' do
      lambda {
        alice.comment 'hello', :on => @status
      }.should change { Comment.count }.by(1)
    end
  end
  describe 'comments' do
    before do
      @remote_message = bob.post :status_message, :message => "hello", :to => @bobs_aspect.id
      @message = alice.post :status_message, :message => "hi", :to => @alices_aspect.id
    end

    it 'should attach the creator signature if the user is commenting' do
      comment = alice.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.reset
      @remote_message.comments.first.signature_valid?.should be_true
    end

    it 'should sign the comment if the user is the post creator' do
      message = alice.post :status_message, :message => "hi", :to => @alices_aspect.id
      alice.comment "Yeah, it was great", :on => message
      message.comments.reset
      message.comments.first.signature_valid?.should be_true
      message.comments.first.verify_post_creator_signature.should be_true
    end

    it 'should verify a comment made on a remote post by a different contact' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
      comment.post_creator_signature = comment.send(:sign_with_key, alice.encryption_key)
      comment.verify_post_creator_signature.should be_true
    end

    it 'should reject comments on a remote post with only a creator sig' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
    end

    it 'should receive remote comments on a user post with a creator sig' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @message)
      comment.creator_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
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
end
