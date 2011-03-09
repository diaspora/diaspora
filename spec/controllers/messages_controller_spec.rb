#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MessagesController do
  render_views

  before do
    @user1 = alice
    @user2 = bob

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first

    sign_in :user, @user1
  end

  describe '#create' do
    before do
      @create_hash = { :author => @user1.person, :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
                       :subject => "cool stuff", :text => "stuff"}
    end
    context "on my own post" do
      before do
        @cnv = Conversation.create(@create_hash)
        @message_hash = {:conversation_id => @cnv.id, :message => {:text => "here is something else"}}
      end
      it 'redirects to conversation' do
        lambda{
          post :create, @message_hash
        }.should change(Message, :count).by(1)
        response.code.should == '302'
        response.should redirect_to(conversations_path(:conversation_id => @cnv))
      end
    end

    context "on a post from a contact" do
      before do
        @create_hash[:author] = @user2.person
        @cnv = Conversation.create(@create_hash)
        @message_hash = {:conversation_id => @cnv.id, :message => {:text => "here is something else"}}
      end
      it 'comments' do
        post :create, @message_hash
        response.code.should == '302'
        response.should redirect_to(conversations_path(:conversation_id => @cnv))
      end
      it "doesn't overwrite author_id" do
        new_user = Factory.create(:user)
        @message_hash[:author_id] = new_user.person.id.to_s
        post :create, @message_hash
        Message.find_by_text(@message_hash[:message][:text]).author_id.should == @user1.person.id
      end
      it "doesn't overwrite id" do
        old_message = Message.create(:text => "hello", :author_id => @user1.person.id, :conversation_id => @cnv.id)
        @message_hash[:id] = old_message.id
        post :create, @message_hash
        old_message.reload.text.should == 'hello'
      end
    end
    context 'on a post from a stranger' do
      before do
        @create_hash[:author] = eve.person
        @create_hash[:participant_ids] = [eve.person.id, bob.person.id]
        @cnv = Conversation.create(@create_hash)
        @message_hash = {:conversation_id => @cnv.id, :message => {:text => "here is something else"}}
      end
      it 'posts no comment' do
        post :create, @message_hash
        response.code.should == '406'
      end
    end
  end
end
