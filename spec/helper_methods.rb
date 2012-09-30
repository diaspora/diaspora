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

  def stub_success(address = 'abc@example.com', opts = {})
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    if opts[:diaspora] || host.include?("diaspora")
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => finger_xrd)
      stub_request(:get, "http://#{host}/hcard/users/4c8eccce34b7da59ff000002").to_return(:status => 200, :body => hcard_response)
    else
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => nonseed_finger_xrd)
      stub_request(:get, 'http://evan.status.net/hcard').to_return(:status => 200, :body => evan_hcard)
    end
  end

  def stub_failure(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 500)
  end

  def host_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/host_xrd').read
  end

  def finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/finger_xrd').read
  end

  def hcard_response
    File.open(File.dirname(__FILE__) + '/fixtures/hcard_response').read
  end

  def nonseed_finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/nonseed_finger_xrd').read
  end

  def evan_hcard
    File.open(File.dirname(__FILE__) + '/fixtures/evan_hcard').read
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
