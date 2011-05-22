require 'spec_helper'


describe NotificationsHelper do
  before do
    @user = Factory(:user)
    @person = Factory(:person)
    @post = Factory(:status_message, :author => @user.person)
    @person2 = Factory(:person)
    @notification = Notification.notify(@user, Factory(:like, :author => @person, :post => @post), @person)
    @notification =  Notification.notify(@user, Factory(:like, :author => @person2, :post => @post), @person2)
    
  end
  describe '#notification_people_link' do
    describe 'for a like' do
      it 'displays #{list of actors}' do
        output = notification_people_link(@notification)
        output.should include @person2.name
        output.should include @person.name
      end
    end
  end


  describe '#object_link' do
    describe 'for a like' do
      it 'should include a link to the post' do
        output = object_link(@notification)
        output.should include status_message_path(@post)
      end

      it 'includes the boilerplate translation' do
        output = object_link(@notification)
        output.should include t("#{@notification.popup_translation_key}")
      end
    end
  end
end
