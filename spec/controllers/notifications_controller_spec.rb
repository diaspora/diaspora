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
end
