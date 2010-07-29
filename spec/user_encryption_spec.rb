require File.dirname(__FILE__) + '/spec_helper'
include ApplicationHelper

describe 'user encryption' do
  before :all do
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
    
  end
  before do
    unstub_mocha_stubs
    @user = Factory.create(:user)
    @user.send(:assign_key)
    @user.save
    @person = Factory.create(:person,
      :key_fingerprint => GPGME.list_keys("Remote Friend").first.subkeys.first.fpr,
      :profile => Profile.new(:first_name => 'Remote',
                              :last_name => 'Friend'),
      :email => 'somewhere@else.com',
      :url => 'http://distant-example.com/')
    @person2 = Factory.create(:person,
      :key_fingerprint => GPGME.list_keys("Second Friend").first.subkeys.first.fpr,
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
  
  it 'should remove the key from the keyring on person destroy' do
    person = Factory.create :person
    keyid = person.key_fingerprint
    original_key = person.export_key
    GPGME.list_keys(keyid).count.should be 1
    person.destroy
    GPGME.list_keys(keyid).count.should be 0
    GPGME.import(original_key)
    GPGME.list_keys(keyid).count.should be 1
  end

  it 'should have a key fingerprint' do
    @user.key_fingerprint.should_not be nil
  end

  it 'should retrieve a user key' do
    @user.key.subkeys[0].fpr.should  == @user.key_fingerprint
  end

  describe 'key exchange on friending' do
       it 'should send over a public key' do
      Comment.send(:class_variable_get, :@@queue).stub!(:add_post_request)
      request = @user.send_friend_request_to("http://example.com/")
      Request.build_xml_for([request]).include?( @user.export_key).should be true
    end

    it 'should receive and marshal a public key from a request' do
      person = Factory.build(:person, :url => "http://test.url/" )
      person.key_fingerprint.nil?.should== false
      #should move this to friend request, but i found it here 
      f = person.key_fingerprint
      id = person.id
      original_key = person.export_key
      
      request = Request.instantiate(:to =>"http://www.google.com/", :from => person)
      
      xml = Request.build_xml_for [request]
      person.destroy
      personcount = Person.all.count
      Diaspora::DiasporaParser.store_objects_from_xml(xml)
      Person.all.count.should == personcount + 1
      new_person = Person.first(:url => "http://test.url/")
      new_person.key_fingerprint.nil?.should == false
      new_person.id.should == id
      new_person.key_fingerprint.should == f
      new_person.export_key.should == original_key
    end 
  end

  describe 'signing and verifying' do

    it 'should sign a message on create' do
      message = Factory.create(:status_message, :person => @user)
      message.verify_creator_signature.should be true 
    end
    
    it 'should not be able to verify a message from a person without a key' do 
      person = Factory.create(:person, :key_fingerprint => "123")
      message = Factory.build(:status_message, :person => person)
      message.save(:validate => false)
      message.verify_creator_signature.should be false
    end
    
    it 'should verify a remote signature' do 
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.key)
      message.save(:validate => false)
      message.verify_creator_signature.should be true
    end
    
    it 'should know if the signature is from the wrong person' do
      message = Factory.build(:status_message, :person => @person)
      message.save(:validate => false)
      message.creator_signature = message.send(:sign_with_key,@person.key)
      message.person = @user
      message.verify_creator_signature.should be false
    end
   
    it 'should know if the signature is for the wrong text' do
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign_with_key,@person.key)
      message.message = 'I love VENISON'
      message.save(:validate => false)
      message.verify_creator_signature.should be false
    end
  end

  describe 'sending and recieving signatures' do
    it 'should contain the signature in the xml' do
      message = Factory.create(:status_message, :person => @user)
      xml = message.to_xml.to_s
      xml.include?(message.creator_signature).should be true
    end
    it 'A message with an invalid signature should be rejected' do
      message = Factory.build(:status_message, :person => @person)
      message.creator_signature = message.send(:sign )
      message.save
      xml = Post.build_xml_for([message])
      message.destroy
      Post.count.should be 0
      Diaspora::DiasporaParser.store_objects_from_xml(xml)
      Post.count.should be 0
    end

  end
  describe 'comments' do
    before do
      @remote_message = Factory.build(:status_message, :person => @person)
      @remote_message.creator_signature = @remote_message.send(:sign_with_key,@person.key)
      @remote_message.save 
      @message = Factory.create(:status_message, :person => @user)
    end
    it 'should attach the creator signature if the user is commenting' do
      @user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.first.verify_creator_signature.should be true
    end

    it 'should sign the comment if the user is the post creator' do
      message = Factory.create(:status_message, :person => @user)
      @user.comment "Yeah, it was great", :on => message
      message.comments.first.verify_creator_signature.should be true
      StatusMessage.first(:message => message.message).comments.first.verify_post_creator_signature.should be true
    end
    
    it 'should verify a comment made on a remote post by a different friend' do
      comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,@person2.key)
      comment.verify_creator_signature.should be true
      comment.valid?.should be false
      comment.post_creator_signature = comment.send(:sign_with_key,@person.key)
      comment.verify_post_creator_signature.should be true
      comment.valid?.should be true
    end

    it 'should reject comments on a remote post with only a creator sig' do
        comment = Comment.new(:person => @person2, :text => "balls", :post => @remote_message)
        comment.creator_signature = comment.send(:sign_with_key,@person2.key)
        comment.verify_creator_signature.should be true
        comment.verify_post_creator_signature.should be false
        comment.save.should be false
    end

    it 'should receive remote comments on a user post with a creator sig' do
        comment = Comment.new(:person => @person2, :text => "balls", :post => @message)
        comment.creator_signature = comment.send(:sign_with_key,@person2.key)
        comment.save.should be true
    end

  end
end
