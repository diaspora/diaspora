module HelperMethods
  module Setup
    def build_db_fixtures
      alice = FactoryGirl.create(:user_with_aspect, :username => "alice")
      alices_aspect = alice.aspects.where(:name => "generic").first

      eve   = FactoryGirl.create(:user_with_aspect, :username => "eve")
      eves_aspect = eve.aspects.where(:name => "generic").first

      bob   = FactoryGirl.create(:user_with_aspect, :username => "bob")
      bobs_aspect = bob.aspects.where(:name => "generic").first
      FactoryGirl.create(:aspect, :name => "empty", :user => bob)

      connect_users(bob, bobs_aspect, alice, alices_aspect)
      connect_users(bob, bobs_aspect, eve, eves_aspect)

      # Set up friends - 2 local, 1 remote
      local_luke = FactoryGirl.create(:user_with_aspect, :username => "luke")
      lukes_aspect = local_luke.aspects.where(:name => "generic").first

      local_leia = FactoryGirl.create(:user_with_aspect, :username => "leia")
      leias_aspect = local_leia.aspects.where(:name => "generic").first

      remote_raphael = FactoryGirl.create(:person, :diaspora_handle => "raphael@remote.net")

      connect_users_with_aspects(local_luke, local_leia)

      local_leia.contacts.create(:person => remote_raphael, :aspects => [leias_aspect])
      local_luke.contacts.create(:person => remote_raphael, :aspects => [lukes_aspect])
    end

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
  end

  module Rspec
    include Setup

    def set_up_friends
      [local_luke, local_leia, remote_raphael]
    end

    def alice
      @alice ||= User.where(:username => 'alice').first
    end

    def bob
      @bob ||= User.where(:username => 'bob').first
    end

    def eve
      @eve ||= User.where(:username => 'eve').first
    end

    def local_luke
      @local_luke ||= User.where(:username => 'luke').first
    end

    def local_leia
      @local_leia ||= User.where(:username => 'leia').first
    end

    def remote_raphael
      @remote_raphael ||= Person.where(:diaspora_handle => 'raphael@remote.net').first
    end

    def photo_fixture_name
      @photo_fixture_name = File.join(File.dirname(__FILE__), 'fixtures', 'button.png')
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
      warn "replace me with a factory method!"
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

  class << self
    include Setup
  end
end
