# TODO: docs
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
      type.each {|type|
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
    a_friend = person.contacts.first.user.person
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

  def first_aspect
    user.aspects.first || FactoryGirl.create(:aspect, user: user)
  end

  def private_status_message
    post = FactoryGirl.create(:status_message, author: person)

    person.contacts.each do |contact|
      ShareVisibility.create!(user_id: contact.user.id, shareable: post)
    end
  end

  %i(photo participation).each do |factory|
    define_method factory do
      FactoryGirl.create(factory, author: person)
    end
  end

  %i[mention role].each do |factory|
    define_method factory do
      FactoryGirl.create(factory, person: person)
    end
  end
end
