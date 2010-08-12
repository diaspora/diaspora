require File.dirname(__FILE__) + '/spec_helper'
include ApplicationHelper
include Diaspora::Parser

describe 'user encryption' do
  before do
    unstub_mocha_stubs
    @user = Factory.create(:user)
    @user.save
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
      request = @user.send_friend_request_to("http://example.com/")
      request.to_diaspora_xml.include?( @user.export_key).should be true
    end

    it 'should receive and marshal a public key from a request' do
      person = Factory.build(:person, :url => "http://test.url/" )
      person.encryption_key.nil?.should== false
      #should move this to friend request, but i found it here 
      id = person.id
      original_key = person.export_key
      
      request = Request.instantiate(:to =>"http://www.google.com/", :from => person)
      
      xml = request.to_diaspora_xml
      person.destroy
      personcount = Person.all.count
      puts xml
      @user.receive xml
      Person.all.count.should == personcount + 1
      new_person = Person.first(:url => "http://test.url/")
      new_person.id.should == id
      new_person.export_key.should == original_key
    end 
  end

  describe 'signing and verifying' do

    it 'should sign a message on create' do
      message = @user.post :status_message, :message => "hi"
      message.verify_creator_signature.should be true 
    end

    it 'should sign a retraction on create' do

      unstub_mocha_stubs
      message = @user.post :status_message, :message => "hi"


      puts "foo"
      retraction = Retraction.for(message)
      puts retraction.inspect 
      retraction.verify_creator_signature.should be true

    end
    
    it 'should not be able to verify a message from a person without a key' do 
      person = Factory.create(:person, :serialized_key => "lskdfhdlfjnh;klsf")
      message = Factory.build(:status_message, :person => person)
      message.save(:validate => false)
      lambda {message.verify_creator_signature.should be false}.should raise_error 
    end
    
    it 'should verify a remote signature' do 
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.save(:validate => false)
      message.verify_creator_signature.should be true
    end
    
    it 'should know if the signature is from the wrong person' do
      message = Factory.build(:status_message, :person => @person)
      message.save(:validate => false)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.person = @user
      message.verify_creator_signature.should be false
    end
   
    it 'should know if the signature is for the wrong text' do
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.encryption_key)
      message.message = 'I love VENISON'
      message.save(:validate => false)
      message.verify_creator_signature.should be false
    end
  end

  describe 'sending and recieving signatures' do
    it 'should contain the signature in the xml' do
      message = @user.post :status_message, :message => "hi"
      xml = message.to_xml.to_s
      xml.include?(message.creator_signature).should be true
    end

    it 'A message with an invalid signature should be rejected' do
      @user2 = Factory.create :user

      message = @user2.post :status_message, :message => "hey"
      message.creator_signature = "totally valid"
      puts message.inspect
      message.save(:validate => false)

      puts message.inspect
      xml = message.to_diaspora_xml
      message.destroy
      puts xml
      Post.count.should be 0
      @user.receive xml
      Post.count.should be 0
    end

  end
  describe 'comments' do
    before do
      @remote_message = Factory.build(:status_message, :person => @person)
      @remote_message.creator_signature = @remote_message.send(:sign_with_key,@person.encryption_key)
      @remote_message.save 
      @message = @user.post :status_message, :message => "hi"
    end
    it 'should attach the creator signature if the user is commenting' do
      @user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.first.verify_creator_signature.should be true
    end

    it 'should sign the comment if the user is the post creator' do
      message = @user.post :status_message, :message => "hi"
      @user.comment "Yeah, it was great", :on => message
      message.comments.first.verify_creator_signature.should be true
      message.comments.first.verify_post_creator_signature.should be true
    end
    
    it 'should verify a comment made on a remote post by a different friend' do
      comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
      comment.verify_creator_signature.should be true
      comment.valid?.should be false
      comment.post_creator_signature = comment.send(:sign_with_key,@person.encryption_key)
      comment.verify_post_creator_signature.should be true
      comment.valid?.should be true
    end

    it 'should reject comments on a remote post with only a creator sig' do
        comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
        comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
        comment.verify_creator_signature.should be true
        comment.verify_post_creator_signature.should be false
        comment.save.should be false
    end

    it 'should receive remote comments on a user post with a creator sig' do
        comment = Comment.new(:person => @person2, :text => "balls", :post => @message)
        comment.creator_signature = comment.send(:sign_with_key,@person2.encryption_key)
        comment.save.should be true
    end

  end
end
