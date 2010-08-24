require File.dirname(__FILE__) + '/spec_helper'
include ApplicationHelper
include Diaspora::Parser

describe 'user encryption' do
  before do
    unstub_mocha_stubs
    @user = Factory.create(:user)
    @group = @user.group(:name => 'dudes')
    @person = Factory.create(:person_with_private_key,
      :profile => Profile.new(:first_name => 'Remote',
                              :last_name => 'Friend'),
      :email => 'somewhere@else.com',
      :url => 'http://distant-example.com/')
    @person2 = Factory.create(:person_with_private_key,
      :profile => Profile.new(:first_name => 'Second',
                              :last_name => 'Friend'),
      :email => 'elsewhere@else.com',
      :url => 'http://distanter-example.com/')
  end

  after  do
    stub_signature_verification
    #gpgdir = File.expand_path("../../db/gpg-#{Rails.env}", __FILE__)
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
  end
  it 'should have a key' do
    @user.encryption_key.should_not be nil
  end
  describe 'key exchange on friending' do
    it 'should send over a public key' do
      message_queue.stub!(:add_post_request)
      request = @user.send_friend_request_to("http://example.com/", @group.id)
      request.to_diaspora_xml.include?( @user.export_key).should be true
    end

    it 'should receive and marshal a public key from a request' do
      remote_user = Factory.build(:user)
      remote_user.encryption_key.nil?.should== false
      #should move this to friend request, but i found it here 
      id = remote_user.person.id
      original_key = remote_user.export_key
      
      request = remote_user.send_friend_request_to(
        @user.receive_url, remote_user.group(:name => "temp").id)
      
      xml = request.to_diaspora_xml
      
      remote_user.person.destroy
      remote_user.destroy
      
      person_count = Person.all.count
      proc {@user.receive xml}.should_not raise_error /Signature was not valid/
      Person.all.count.should == person_count + 1
      new_person = Person.first(:id => id)
      new_person.export_key.should == original_key
    end 
  end

  describe 'signing and verifying' do

    it 'should sign a message on create' do
      message = @user.post :status_message, :message => "hi", :to => @group.id
      message.signature_valid?.should be true 
    end

    it 'should sign a retraction on create' do

      unstub_mocha_stubs
      message = @user.post :status_message, :message => "hi", :to => @group.id


      retraction = @user.retract(message) 
      retraction.signature_valid?.should be true

    end
    
    it 'should not be able to verify a message from a person without a key' do 
      person = Factory.create(:person, :serialized_key => "lskdfhdlfjnh;klsf")
      message = Factory.build(:status_message, :person => person)
      message.save(:validate => false)
      lambda {message.signature_valid?.should be false}.should raise_error 
    end
    
    it 'should verify a remote signature' do 
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.save(:validate => false)
      message.signature_valid?.should be true
    end
    
    it 'should know if the signature is from the wrong person' do
      message = Factory.build(:status_message, :person => @person)
      message.save(:validate => false)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.person = @user
      message.signature_valid?.should be false
    end
   
    it 'should know if the signature is for the wrong text' do
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.message = 'I love VENISON'
      message.save(:validate => false)
      message.signature_valid?.should be false
    end
  end

  describe 'sending and recieving signatures' do
    it 'should contain the signature in the xml' do
      message = @user.post :status_message, :message => "hi", :to => @group.id
      xml = message.to_xml.to_s
      xml.include?(message.creator_signature).should be true
    end

    it 'A message with an invalid signature should be rejected' do
      @user2 = Factory.create :user

      message = @user2.post :status_message, :message => "hey", :to => @user2.group(:name => "bruisers").id
      message.creator_signature = "totally valid"
      message.save(:validate => false)

      xml = message.to_diaspora_xml
      message.destroy
      Post.count.should be 0
      proc {@user.receive xml}.should raise_error /Signature was not valid/
      Post.count.should be 0
    end

  end
  describe 'comments' do
    before do
      @remote_message = Factory.build(:status_message, :person => @person)
      @remote_message.creator_signature = @remote_message.send(:sign_with_key,@person.encryption_key)
      @remote_message.save 
      @message = @user.post :status_message, :message => "hi", :to => @group.id
    end
    it 'should attach the creator signature if the user is commenting' do
      @user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.first.signature_valid?.should be true
    end

    it 'should sign the comment if the user is the post creator' do
      message = @user.post :status_message, :message => "hi", :to => @group.id
      @user.comment "Yeah, it was great", :on => message
      message.comments.first.signature_valid?.should be true
      message.comments.first.verify_post_creator_signature.should be true
    end

    it 'should verify a comment made on a remote post by a different friend' do
      comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
      comment.post_creator_signature = comment.send(:sign_with_key,@person.encryption_key)
      comment.verify_post_creator_signature.should be true
    end

    it 'should reject comments on a remote post with only a creator sig' do
      comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
    end

    it 'should receive remote comments on a user post with a creator sig' do
      comment = Comment.new(:person => @person2, :text => "balls", :post => @message)
      comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
    end

  end
end
