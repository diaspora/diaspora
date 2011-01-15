#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController do

  let!(:user) { Factory.create(:user) }
  let!(:aspect) { user.aspects.create(:name => "AWESOME!!") }

  before do
    sign_in :user, user
  end

  describe '#update' do
    it 'marks a notification as read' do
      note = Notification.create(:recipient_id => user.id)
      put :update, :id => note.id
      Notification.first.unread.should == false
    end

    it 'only lets you read your own notifications' do
      user2 = Factory.create(:user)

      Notification.create(:recipient_id => user.id)
      note = Notification.create(:recipient_id => user2.id)

      put :update, :id => note.id

      Notification.find(note.id).unread.should == true
    end
  end

  describe "#read_all" do
    it 'marks all notifications as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      Notification.create(:recipient_id => user.id)
      Notification.create(:recipient_id => user.id)

      Notification.where(:unread => true).count.should == 2
      get :read_all
      Notification.where(:unread => true).count.should == 0
    end
  end

  describe '#index' do
    it 'paginates the notifications' do
      35.times do
        Notification.create(:recipient_id => user.id)
      end

      get :index
      assigns[:notifications].count.should == 25

      get :index, :page => 2
      assigns[:notifications].count.should == 10
    end
  end
end
