#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  let(:user)    {alice}
  let(:aspect)  {user.aspects.first}

  let(:user2)   {bob}
  let(:aspect2) {user2.aspects.first}


 describe 'comment#notification_type' do
   let(:user3)   {Factory(:user)}
   let(:aspect3) {user3.aspects.create(:name => "Faces")}
   let!(:connecting2) { connect_users(user, aspect, user3, aspect3) }
   before do
     @post2 = user2.post(:status_message, :message => 'yo', :to => aspect2.id)
     @post1 = user.post(:status_message, :message => "hello", :to => aspect.id)
     @c11 = user2.comment "why so formal?", :on => @post1
     @c12 = user.comment "I simply felt like issuing a greeting.  Do step off.", :on => @post1
     @c22 = user2.comment "I simply felt like issuing a greeting.  Do step off.", :on => @post2
   end

   it "returns 'comment_on_post' if the comment is on a post you own" do
     @c11.notification_type(user, user2.person).should == 'comment_on_post'
   end

   it 'returns false if the comment is not on a post you own and noone "also_commented"' do
     @c12.notification_type(user3, user.person).should == false
   end

   context "also commented" do
     before do
       @c13 = user3.comment "I also commented on the first user's post", :on => @post1
     end

     it 'does not return also commented if the user commented' do
       @c13.notification_type(user3, user.person).should == false
     end

     it "returns 'also_commented' if another person commented on a post you commented on" do
       @c13.notification_type(user2, user.person).should == 'also_commented'
     end
    end
  end





  describe 'User#comment' do
    before do
      @status = user.post(:status_message, :message => "hello", :to => aspect.id)
    end

    it "should be able to comment on his own status" do
      @status.comments.should == []

      user.comment "Yeah, it was great", :on => @status
      @status.reload.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a person's status" do
      user2.comment "sup dog", :on => @status
      @status.reload.comments.first.text.should == "sup dog"
    end
  end

  context 'comment propagation' do
    before do
      @person = Factory.create(:person)
      user.activate_contact(@person, aspect)

      @person2 = Factory.create(:person)
      @person3 = Factory.create(:person)
      user.activate_contact(@person3, aspect)

      @person_status = Factory.create(:status_message, :person => @person)

      user.reload
      @user_status = user.post :status_message, :message => "hi", :to => aspect.id

      aspect.reload
      user.reload
    end

    it 'should send the comment to the postman' do
      m = mock()
      m.stub!(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)
      user.comment "yo", :on => @person_status
    end

    describe '#subscribers' do
      it 'returns the posts original audience, if the post is owned by the user' do
        comment = user.build_comment "yo", :on => @person_status
        comment.subscribers(user).should =~ [@person]
      end

      it 'returns the owner of the original post, if the user owns the comment' do
        comment = user.build_comment "yo", :on => @user_status
        comment.subscribers(user).map{|s| s.id}.should =~ [@person, @person3, user2.person].map{|s| s.id}
      end
    end

  context 'testing a method only used for testing' do
    it "should send a user's comment on a person's post to that person" do
      m = mock()
      m.stub!(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)

      user.comment "yo", :on => @person_status
    end
  end

    it 'should not clear the aspect post array on receiving a comment' do
      aspect.post_ids.include?(@user_status.id).should be_true
      comment = Comment.new(:person_id => @person.id, :text => "cats", :post => @user_status)

      zord = Postzord::Receiver.new(user, :person => @person)
      zord.parse_and_receive(comment.to_diaspora_xml)

      aspect.reload
      aspect.post_ids.include?(@user_status.id).should be_true
    end
  end
  describe 'xml' do
    before do
      @commenter = Factory.create(:user)
      @commenter_aspect = @commenter.aspects.create(:name => "bruisers")
      connect_users(user, aspect, @commenter, @commenter_aspect)
      @post = user.post :status_message, :message => "hello", :to => aspect.id
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
      @status = user.post(:status_message, :message => "hello", :to => aspect.id)
    end
    it 'does not multi-post a comment' do
      lambda {
        user.comment 'hello', :on => @status
      }.should change{Comment.count}.by(1)
    end
  end
  describe 'comments' do
    before do
      @remote_message = user2.post :status_message, :message => "hello", :to => aspect2.id
      @message = user.post :status_message, :message => "hi", :to => aspect.id
    end

    it 'should attach the creator signature if the user is commenting' do
      comment = user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.reset
      @remote_message.comments.first.signature_valid?.should be_true
    end

    it 'should sign the comment if the user is the post creator' do
      message = user.post :status_message, :message => "hi", :to => aspect.id
      user.comment "Yeah, it was great", :on => message
      message.comments.reset
      message.comments.first.signature_valid?.should be_true
      message.comments.first.verify_post_creator_signature.should be_true
    end

    it 'should verify a comment made on a remote post by a different contact' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
      comment.post_creator_signature = comment.send(:sign_with_key,user.encryption_key)
      comment.verify_post_creator_signature.should be_true
    end

    it 'should reject comments on a remote post with only a creator sig' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
    end

    it 'should receive remote comments on a user post with a creator sig' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_post_creator_signature.should be_false
    end
  end

  describe 'youtube' do
    before do
      @message = user.post :status_message, :message => "hi", :to => aspect.id
    end
    it 'should process youtube titles on the way in' do
      video_id = "ABYnqp-bxvg"
      url="http://www.youtube.com/watch?v=#{video_id}&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
      expected_title = "UP & down & UP & down &amp;"

      mock_http = mock("http")
      Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
      mock_http.should_receive(:get).with('/feeds/api/videos/'+video_id+'?v=2', nil).and_return(
        [nil, 'Foobar <title>'+expected_title+'</title> hallo welt <asd><dasdd><a>dsd</a>'])

      comment = user.build_comment url, :on => @message

      comment.save!
      Comment.find(comment.id).youtube_titles.should == {video_id => CGI::escape(expected_title)}
    end
  end
end
