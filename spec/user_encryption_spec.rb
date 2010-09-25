#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'
include ApplicationHelper
include Diaspora::Parser

describe 'user encryption' do
  before do
    unstub_mocha_stubs
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => 'dudes')
    @person = Factory.create(:person_with_private_key,
      :profile => Profile.new(:first_name => 'Remote',
                              :last_name => 'Friend'),
      :diaspora_handle => 'somewhere@else.com',
      :url => 'http://distant-example.com/')
    @person2 = Factory.create(:person_with_private_key,
      :profile => Profile.new(:first_name => 'Second',
                              :last_name => 'Friend'),
      :diaspora_handle => 'elsewhere@else.com',
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
      request = @user.send_friend_request_to(Factory.create(:person), @aspect)
      request.to_diaspora_xml.include?( @user.exported_key).should be true
    end

    it 'should receive and marshal a public key from a request' do
      remote_user = Factory.build(:user)
      remote_user.encryption_key.nil?.should== false
      #should move this to friend request, but i found it here
      id = remote_user.person.id
      original_key = remote_user.exported_key

      request = remote_user.send_friend_request_to(
        @user.person, remote_user.aspect(:name => "temp"))

      xml = request.to_diaspora_xml

      remote_user.person.destroy
      remote_user.destroy

      person_count = Person.all.count
      proc {@user.receive xml}.should_not raise_error /ignature was not valid/
      Person.all.count.should == person_count + 1
      new_person = Person.first(:id => id)
      new_person.exported_key.should == original_key
    end
  end

  describe 'encryption' do
    before do
      @message = @user.post :status_message, :message => "hi", :to => @aspect.id
    end
    it 'should encrypt large messages' do
      ciphertext = @user.encrypt @message.to_diaspora_xml
      ciphertext.include?(@message.to_diaspora_xml).should be false
      @user.decrypt(ciphertext).include?(@message.to_diaspora_xml).should be true
    end
  end

  describe 'comments' do
    before do
      @remote_message = Factory.create(:status_message, :person => @person)
      @message = @user.post :status_message, :message => "hi", :to => @aspect.id
    end
    it 'should attach the creator signature if the user is commenting' do
      @user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.first.signature_valid?.should be true
    end

    it 'should sign the comment if the user is the post creator' do
      message = @user.post :status_message, :message => "hi", :to => @aspect.id
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
