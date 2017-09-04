
# frozen_string_literal: true

require Rails.root.join("spec", "support", "inlined_jobs")

module HelperMethods
  def connect_users_with_aspects(u1, u2)
    aspect1, aspect2 = [u1, u2].map do |user|
      user.aspects.where(name: "Besties").first.presence || user.aspects.first
    end
    connect_users(u1, aspect1, u2, aspect2)
  end

  def connect_users(user1, aspect1, user2, aspect2)
    user1.contacts.create!(:person => user2.person,
                           :aspects => [aspect1],
                           :sharing => true,
                           :receiving => true)

    user2.contacts.create!(:person => user1.person,
                           :aspects => [aspect2],
                           :sharing => true,
                           :receiving => true)
  end

  def uploaded_photo
    fixture_filename = 'button.png'
    fixture_name = File.join(File.dirname(__FILE__), 'fixtures', fixture_filename)
    File.open(fixture_name)
  end

  def create_conversation_with_message(sender_person, recipient_person, subject, text)
    create_hash = {
      author:              sender_person,
      participant_ids:     [sender_person.id, recipient_person.id],
      subject:             subject,
      messages_attributes: [{author: sender_person, text: text}]
    }

    Conversation.create!(create_hash)
  end

  def get_response_for_user_agent(app, userAgent)
    env = Rack::MockRequest.env_for('/', "HTTP_USER_AGENT" => userAgent)
    status, headers, body = app.call(env)
    body.close if body.respond_to?(:close) # avoids deadlock after 3 tests
    ActionDispatch::TestResponse.new(status, headers, body)
  end

  def text_mentioning(*people)
    people.map {|person|
      "this is a text mentioning @{#{person.diaspora_handle}} ... have fun testing!"
    }.join(" ")
  end

  def build_relayable_federation_entity(type, data={}, additional_data={})
    attributes = Fabricate.attributes_for("#{type}_entity".to_sym, data)
    entity_class = "DiasporaFederation::Entities::#{type.to_s.camelize}".constantize
    signable_fields = attributes.keys - %i[author_signature parent]

    entity_class.new(attributes, [*signable_fields, *additional_data.keys], additional_data)
  end
end
