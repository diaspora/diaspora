
require Rails.root.join("spec", "support", "inlined_jobs")

module HelperMethods
  def connect_users_with_aspects(u1, u2)
    aspect1 = u1.aspects.length == 1 ? u1.aspects.first : u1.aspects.where(:name => "Besties").first
    aspect2 = u2.aspects.length == 1 ? u2.aspects.first : u2.aspects.where(:name => "Besties").first
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

  def create_conversation_with_message(sender, recipient_person, subject, text)
    create_hash = {
      :author => sender.person,
      :participant_ids => [sender.person.id, recipient_person.id],
      :subject => subject,
      :messages_attributes => [ {:author => sender.person, :text => text} ]
    }

    Conversation.create!(create_hash)
  end

  def get_response_for_user_agent(app, userAgent)
    env = Rack::MockRequest.env_for('/', "HTTP_USER_AGENT" => userAgent)
    status, headers, body = app.call(env)
    body.close if body.respond_to?(:close) # avoids deadlock after 3 tests
    ActionDispatch::TestResponse.new(status, headers, body)
  end
end
