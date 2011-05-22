require 'spec_helper'


describe NotificationsHelper do
  describe '#notification_people_link' do
    describe 'for a like' do
      it 'displays #{list of actors}' do
        @user = Factory(:user)
        @person = Factory(:person)
        p = Factory(:status_message, :author => @user.person)
        person2 = Factory(:person)
        notification = Notification.notify(@user, Factory(:like, :author => @person, :post => p), @person)
        notification2 =  Notification.notify(@user, Factory(:like, :author => person2, :post => p), person2)
        
        output = notification_people_link(notification2)
        output.should include person2.name
        output.should include @person.name
      end
    end
  end
end
