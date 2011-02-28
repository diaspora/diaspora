#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Relayable do

  before do
    @alices_aspect = alice.aspects.first
    @bobs_aspect = bob.aspects.first
    @remote_message = bob.post :status_message, :message => "hello", :to => @bobs_aspect.id
    @message = alice.post :status_message, :message => "hi", :to => @alices_aspect.id
  end

  describe '#parent_author_signature' do
    it 'should sign the comment if the user is the post author' do
      message = alice.post :status_message, :message => "hi", :to => @alices_aspect.id
      alice.comment "Yeah, it was great", :on => message
      message.comments.reset
      message.comments.first.signature_valid?.should be_true
      message.comments.first.verify_parent_author_signature.should be_true
    end

    it 'should verify a comment made on a remote post by a different contact' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @remote_message)
      comment.author_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_parent_author_signature.should be_false
      comment.parent_author_signature = comment.send(:sign_with_key, alice.encryption_key)
      comment.verify_parent_author_signature.should be_true
    end
  end

  describe '#author_signature' do
    it 'should attach the author signature if the user is commenting' do
      comment = alice.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.reset
      @remote_message.comments.first.signature_valid?.should be_true
    end

    it 'should reject comments on a remote post with only a author sig' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @remote_message)
      comment.author_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_parent_author_signature.should be_false
    end

    it 'should receive remote comments on a user post with a author sig' do
      comment = Comment.new(:person => bob.person, :text => "cats", :post => @message)
      comment.author_signature = comment.send(:sign_with_key, bob.encryption_key)
      comment.signature_valid?.should be_true
      comment.verify_parent_author_signature.should be_false
    end
  end

end

