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

  describe '#destroy' do
    it 'removes a notification' do
      note = Notification.create(:user_id => user.id)
      delete :destroy, :id => note.id
      Notification.count.should == 0 
    end

    it 'only lets you delete your own notifications' do
      user2 = make_user

      Notification.create(:user_id => user.id)
      note = Notification.create(:user_id => user2.id)

      delete :destroy, :id => note.id

      Notification.count.should == 2 
    end
  end
end
