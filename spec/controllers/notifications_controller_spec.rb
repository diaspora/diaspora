#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController do
  before do
    @user   = alice
    @aspect = @user.aspects.first
    sign_in :user, @user
  end

  describe '#update' do
    it 'marks a notification as read' do
      note = Factory(:notification, :recipient => @user)
      put :update, :id => note.id
      Notification.first.unread.should == false
    end

    it 'only lets you read your own notifications' do
      user2 = bob

      Factory(:notification, :recipient => @user)
      note = Factory(:notification, :recipient => user2)

      put :update, :id => note.id

      Notification.find(note.id).unread.should == true
    end
  end

  describe "#read_all" do
    it 'marks all notifications as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      Factory(:notification, :recipient => @user)
      Factory(:notification, :recipient => @user)

      Notification.where(:unread => true).count.should == 2
      get :read_all
      Notification.where(:unread => true).count.should == 0
    end
  end

  describe '#index' do
    it 'paginates the notifications' do
      26.times do
        Factory(:notification, :recipient => @user)
      end

      get :index
      assigns[:notifications].count.should == 25

      get :index, :page => 2
      assigns[:notifications].count.should == 1
    end
  end
end