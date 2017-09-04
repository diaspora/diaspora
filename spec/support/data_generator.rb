# frozen_string_literal: true

# This is a helper class for tests that is capable of generating different sets of data, which are possibly
# interrelated.
class DataGenerator
  def person
    @person || user.person
  end

  def user
    @user || person.owner
  end

  def initialize(user_or_person)
    if user_or_person.is_a? User
      @user = user_or_person
    elsif user_or_person.is_a? Person
      @person = user_or_person
    else
      raise ArgumentError
    end
  end

  def self.create(user_or_person, type)
    generator = new(user_or_person)
    if type.is_a? Symbol
      generator.send(type)
    elsif type.is_a? Array
      type.map {|type|
        generator.send(type)
      }
    end
  end

  def generic_user_data
    preferences
    notifications
    blocks
    service
    private_post_as_receipient
    tag_following
    generic_person_data
    remote_mutual_friend
  end

  def generic_person_data
    private_status_message
    mention
    photo
    conversations
    role
    participation
  end

  def preferences
    %w[mentioned liked reshared].each do |pref|
      user.user_preferences.create!(email_type: pref)
    end
  end

  def notifications
    FactoryGirl.create(:notification, recipient: user)
  end

  def conversations
    a_friend = FactoryGirl.create(:contact, person: person).user.person
    FactoryGirl.create(:contact, user: user, person: a_friend) unless user.nil?
    create_conversation_with_message(a_friend, person, "Subject", "Hey #{person.name}")
    create_conversation_with_message(person, a_friend, "Subject", "Hey #{a_friend.name}")
  end

  def blocks
    user.blocks.create!(person: eve.person)
    eve.blocks.create!(person: person)
  end

  def service
    FactoryGirl.create(:service, user: user)
  end

  def private_post_as_receipient
    friend = mutual_friend
    friend.post(
      :status_message,
      text: text_mentioning(user),
      to:   friend.aspects.first
    )
  end

  def tag_following
    TagFollowing.create!(tag: random_tag, user: user)
  end

  def random_tag
    ActsAsTaggableOn::Tag.create!(name: "partytimeexcellent#{r_str}")
  end

  def mutual_friend
    FactoryGirl.create(:user_with_aspect).tap {|friend|
      connect_users(user, first_aspect, friend, friend.aspects.first)
    }
  end

  def remote_mutual_friend
    FactoryGirl.create(:contact, user: user, sharing: true, receiving: true)
  end

  def first_aspect
    user.aspects.first || FactoryGirl.create(:aspect, user: user)
  end

  def public_status_message
    FactoryGirl.create(:status_message, author: person, public: true)
  end

  def private_status_message
    post = FactoryGirl.create(:status_message, author: person)

    person.contacts.each do |contact|
      ShareVisibility.create!(user_id: contact.user_id, shareable: post)
    end
  end

  %i[photo participation status_message_with_location status_message_with_poll status_message_with_photo
     status_message status_message_in_aspect reshare like comment poll_participation].each do |factory|
    define_method factory do
      FactoryGirl.create(factory, author: person)
    end
  end

  alias subscription participation

  %i[mention role].each do |factory|
    define_method factory do
      FactoryGirl.create(factory, person: person)
    end
  end

  def status_message_with_activity
    status_message_with_poll.tap {|post|
      mutual_friend.like!(post)
      mutual_friend.comment!(post, "1")
      mutual_friend.participate_in_poll!(post, post.poll.poll_answers.first)
    }
  end

  def status_message_with_comment
    post = status_message_in_aspect
    [post, mutual_friend.comment!(post, "some text")]
  end

  def status_message_with_like
    post = status_message_in_aspect
    [post, mutual_friend.like!(post)]
  end

  def status_message_with_poll_participation
    post = status_message_with_poll
    [
      post,
      mutual_friend.participate_in_poll!(post, post.poll.poll_answers.first)
    ]
  end

  def activity
    reshare
    like
    comment
    poll_participation
  end

  def work_aspect
    user.aspects.create(name: "Work", contacts_visible: false)
  end

  def status_messages_flavours
    public_status_message
    status_message_with_location
    status_message_with_activity
    status_message_with_photo
    status_message_with_poll
    status_message_in_aspect
  end

  def status_message_with_subscriber
    [
      mutual_friend,
      status_message_in_aspect
    ]
  end
end
