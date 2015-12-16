
require 'spec_helper'

module MentioningSpecHelpers
  def default_aspect
    @user1.aspects.where(name: 'generic').first
  end

  def text_mentioning(user)
    handle = user.diaspora_handle
    "this is a text mentioning @{Mention User ; #{handle}} ... have fun testing!"
  end

  def notifications_about_mentioning(user)
    Notifications::Mentioned.where(recipient_id: user.id)
  end

  def stream_for(user)
    stream = Stream::Multi.new(user)
    stream.posts
  end

  def users_connected?(user1, user2)
    user1.contacts.where(person_id: user2.person).count > 0
  end
end


describe 'mentioning', :type => :request do
  include MentioningSpecHelpers

  before do
    @user1 = FactoryGirl.create :user_with_aspect
    @user2 = FactoryGirl.create :user
    @user3 = FactoryGirl.create :user

    @user1.share_with(@user2.person, default_aspect)
  end

  # see: https://github.com/diaspora/diaspora/issues/4160
  it 'only mentions people that are in the target aspect' do
    expect(users_connected?(@user1, @user2)).to be true
    expect(users_connected?(@user1, @user3)).to be false

    status_msg = nil
    expect do
      status_msg = @user1.post(:status_message, {text: text_mentioning(@user3), to: default_aspect})
    end.to change(Post, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be false
    expect(status_msg.text).to include(@user3.name)

    expect(notifications_about_mentioning(@user3)).to be_empty
    expect(stream_for(@user3).map { |item| item.id }).not_to include(status_msg.id)
  end

end
