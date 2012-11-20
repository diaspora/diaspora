#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MessagesController do
  before do
    sign_in :user, alice
  end

  describe '#create' do
    before do
      @conversation_params = {
        :author              => alice.person,
        :participant_ids     => [alice.contacts.first.person.id, alice.person.id],
        :subject             => 'cool stuff',
        :messages_attributes => [ {:author => alice.person, :text => 'stuff'} ]
      }
    end

    context "on my own post" do
      before do
        @conversation = Conversation.create!(@conversation_params)
      end

      context "with a valid message" do
        before do
          @message_params = {
            :conversation_id => @conversation.id,
            :message         => { :text => "here is something else" }
          }
        end

        it 'redirects to conversation' do
          lambda {
            post :create, @message_params
          }.should change(Message, :count).by(1)
          response.status.should == 302
          response.should redirect_to(conversations_path(:conversation_id => @conversation))
        end
      end

      context "with an empty message" do
        before do
          @message_params = {
            :conversation_id => @conversation.id,
            :message         => { :text => " " }
          }
        end

        it 'does not create the message' do
          lambda {
            post :create, @message_params
          }.should_not change(Message, :count)
          flash[:error].should be_present
        end
      end
    end

    context "on a post from a contact" do
      before do
        @conversation_params[:author] = bob.person
        @conversation = Conversation.create!(@conversation_params)
        @message_params = {
          :conversation_id => @conversation.id,
          :message         => { :text => "here is something else" }
        }
      end

      it 'comments' do
        post :create, @message_params
        response.status.should == 302
        response.should redirect_to(conversations_path(:conversation_id => @conversation))
      end

      it "doesn't overwrite author_id" do
        new_user = FactoryGirl.create(:user)
        @message_params[:author_id] = new_user.person.id.to_s

        post :create, @message_params
        created_message = Message.find_by_text(@message_params[:message][:text])
        created_message.author.should == alice.person
      end

      it "doesn't overwrite id" do
        old_message = Message.create!(
          :text            => "hello",
          :author_id       => alice.person.id,
          :conversation_id => @conversation.id
        )
        @message_params[:id] = old_message.id

        post :create, @message_params
        old_message.reload.text.should == 'hello'
      end
    end

    context 'on a post from a stranger' do
      before do
        conversation = Conversation.create!(
          :author          => eve.person,
          :participant_ids => [eve.person.id, bob.person.id]
        )
        @message_params = {
          :conversation_id => conversation.id,
          :message         => { :text => "here is something else" }
        }
      end

      it 'does not create the message' do
        lambda {
          post :create, @message_params
        }.should_not change(Message, :count)
        flash[:error].should be_present
      end
    end
  end
end
