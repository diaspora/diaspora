#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Notifications::PrivateMessage do
    before do
      @user1 = alice
      @user2 = bob
      @user3 = FactoryGirl.create(:user_with_aspect, :username => "peter")
      
      connect_users_with_aspects(@user1, @user3)

      @create_hash = {
        :author => @user1.person,
        :participant_ids => [@user1.person.id, @user2.person.id, @user3.person.id],
        :subject => 'cool stuff',
        :messages_attributes => [ {:author => @user1.person, :text => 'stuff'} ]
      }

      @cnv = Conversation.create(@create_hash)
      @msg = @cnv.messages.first
    end

    describe '#make_notification' do
      it 'does not save the notification' do
        lambda{
          Notification.notify(@user2, @msg, @user1.person)
        }.should_not change(Notification, :count)
      end

      it 'does increase notification count for recipient if author creates a message' do
        expect { 
          @cnv.messages.build(:text => "this is cool", :author => @user1.person) 
        }.to change(
          ConversationVisibility.where(
            :conversation_id => @cnv.id, 
            :person_id => @user2.person.id
          ).first, :unread).by(1)
      end

      it 'does not increase own notification if author creates a message' do
        expect { 
          @cnv.messages.build(:text => "this is cool", :author => @user1.person) 
        }.to_not change(
          ConversationVisibility.where(
            :conversation_id => @cnv.id, 
            :person_id => @user1.person.id
            ).first, :unread).by(1)
      end
      
      it 'does not increase own notification if recipient creates a message' do
        expect {
          @cnv.messages.build(:text => "this is cool",:author => @user2.person) 
        }.to_not change(
          ConversationVisibility.where(
            :conversation_id => @cnv.id, 
            :person_id => @user2.person.id
          ).first, :unread).by(1)
      end
      
      it 'does increase notification count for author if recipient creates a message' do
        expect {
          @cnv.messages.build(:text => "this is cool", :author => @user2.person) 
        }.to change(
          ConversationVisibility.where(
            :conversation_id => @cnv.id, 
            :person_id => @user1.person.id
          ).first, :unread).by(1)
      end
      
      it 'does increase notification counts for other recipient if recipient creates a message' do
        expect {
          @cnv.messages.build(:text => "this is cool", :author => @user2.person) 
        }.to change(
          ConversationVisibility.where(
            :conversation_id => @cnv.id, 
            :person_id => @user3.person.id
          ).first, :unread).by(1)
      end
      
      it 'does email the user' do
        opts = {
          :actors => [@user1.person],
          :recipient_id => @user2.id}

        n = Notifications::PrivateMessage.new(opts)
        Notifications::PrivateMessage.stub!(:make_notification).and_return(n)
        Notification.notify(@user2, @msg, @user1.person)
        n.stub!(:recipient).and_return @user2

        @user2.should_receive(:mail)
        n.email_the_user(@msg, @user1.person)
      end
    end
end
 
