require 'spec_helper'


describe NotificationsHelper, :type => :helper do
  include ApplicationHelper

  before do
    @user = FactoryGirl.create(:user)
    @person = FactoryGirl.create(:person)
    @post = FactoryGirl.create(:status_message, :author => @user.person)
    @person2 = FactoryGirl.create(:person)
    @notification = Notification.notify(@user, FactoryGirl.create(:like, :author => @person, :target => @post), @person)
    @notification =  Notification.notify(@user, FactoryGirl.create(:like, :author => @person2, :target => @post), @person2)
  end

  describe '#notification_people_link' do
    context 'formatting' do
      include ActionView::Helpers::SanitizeHelper
      let(:output){ strip_tags(notification_people_link(@note)) }

      before do
        @max = FactoryGirl.create(:person)
        @max.profile.first_name = 'max'
        @max.profile.last_name = 'salzberg'
        @sarah = FactoryGirl.create(:person)
        @sarah.profile.first_name = 'sarah'
        @sarah.profile.last_name = 'mei'


        @daniel = FactoryGirl.create(:person)
        @daniel.profile.first_name = 'daniel'
        @daniel.profile.last_name = 'grippi'

        @ilya = FactoryGirl.create(:person)
        @ilya.profile.first_name = 'ilya'
        @ilya.profile.last_name = 'zhit'
        @note = double()
      end

      it 'with two, does not comma seperate two actors' do
        allow(@note).to receive(:actors).and_return([@max, @sarah])
        expect(output.scan(/,/)).to be_empty
        expect(output.scan(/and/).count).to be 1
      end

      it 'with three, comma seperates the first two, and and the last actor' do
        allow(@note).to receive(:actors).and_return([@max, @sarah, @daniel])
        expect(output.scan(/,/).count).to be 2
        expect(output.scan(/and/).count).to be 1
      end

      it 'with more than three, lists the first three, then the others tag' do
        allow(@note).to receive(:actors).and_return([@max, @sarah, @daniel, @ilya])
        expect(output.scan(/,/).count).to be 3
        expect(output.scan(/and/).count).to be 2
      end
    end
    describe 'for a like' do
      it 'displays #{list of actors}' do
        output = notification_people_link(@notification)
        expect(output).to include @person2.name
        expect(output).to include @person.name
      end
    end
  end


  describe '#object_link' do
    describe 'for a like' do
      it 'should include a link to the post' do
        output = object_link(@notification, notification_people_link(@notification))
        expect(output).to include post_path(@post)
      end

      it 'includes the boilerplate translation' do
        output = object_link(@notification, notification_people_link(@notification))
        expect(output).to include I18n.t("#{@notification.popup_translation_key}",
                                     :actors => notification_people_link(@notification),
                                     :count => @notification.actors.count,
                                     :post_link => link_to(post_page_title(@post), post_path(@post), 'data-ref' => @post.id, :class => 'hard_object_link').html_safe)
      end

      context 'when post is deleted' do
        it 'works' do
          @post.destroy
          expect{ object_link(@notification, notification_people_link(@notification))}.to_not raise_error
        end

        it 'displays that the post was deleted' do
          @post.destroy
          expect(object_link(@notification,  notification_people_link(@notification))).to eq(t('notifications.liked_post_deleted.one', :actors => notification_people_link(@notification)))
        end
      end
    end
  end
end
