#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController do

  let!(:user) { make_user }
  let!(:aspect) { user.aspects.create(:name => "AWESOME!!") }
  
  before do
    sign_in :user, user

  end

  describe '#update' do
    it 'marks a notification as read' do
      note = Notification.create(:user_id => user.id)
      put :update, :id => note.id
      Notification.first.unread.should == false
    end

    it 'only lets you read your own notifications' do
      user2 = make_user

      Notification.create(:user_id => user.id)
      note = Notification.create(:user_id => user2.id)

      put :update, :id => note.id

      Notification.find(note.id).unread.should == true 
    end
  end
  
  describe '#index' do
    it 'paginates the notifications' do
      35.times do
        Notification.create(:user_id => user.id)
      end
      
      get :index
      assigns[:notifications].should == Notification.all(:user_id => user.id, :limit => 25)
      
      get :index, :page => 2
      assigns[:notifications].should == Notification.all(:user_id => user.id, :offset => 25, :limit => 25)
    end
  end
end
