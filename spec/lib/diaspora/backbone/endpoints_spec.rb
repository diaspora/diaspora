
require 'spec_helper'
require 'rack/test'

def parse_json(content)
  JSON.parse(content, symbolize_names: true)
end

RSpec::Matchers.define :be_json do
  match do |actual|
    actual.header["Content-Type"].include?("application/json")
  end
end

RSpec::Matchers.define :be_successful do |payload|
  match do |actual|
    result = true

    unless actual.body.empty?
      body = parse_json(actual.body)
      result = true
      payload.each do |key, val|
        result = (result && body[key].include?(val)) if val.is_a?(String)
      end unless payload.nil?
    end

    (actual.status == 200 && result)
  end
end

RSpec::Matchers.define :be_404 do
  match do |actual|
    (actual.status == 404 &&
     parse_json(actual.body)[:message] == "Not found!")
  end
end

RSpec::Matchers.define :be_401 do
  match do |actual|
    (actual.status == 401 &&
     parse_json(actual.body)[:message] == "Unauthorized!")
  end
end

RSpec::Matchers.define :be_400 do
  match do |actual|
    (actual.status == 400 &&
     parse_json(actual.body)[:message] == "Bad request!")
  end
end


describe Diaspora::Backbone::Endpoints do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(described_class, "backbone.test")) }
  # beware: this is cached within the same example!
  # use `browser.last_response` if you have to follow a redirect or send multiple requests
  let(:response) { browser.last_response }

  after do
    Warden.test_reset!
  end

  context "base" do
    it "responds with json at the root" do
      browser.get("/")
      response.should be_successful({message: "internal diaspora* Backbone.js API"})
      response.should be_json
    end

    it "responds with 404 json at misc paths" do
      browser.get("/abc")
      browser.last_response.should be_404
      browser.last_response.should be_json

      browser.get("/a-b-c")
      browser.last_response.should be_404
      browser.last_response.should be_json

      browser.get("/a/b/c")
      browser.last_response.should be_404
      browser.last_response.should be_json
    end
  end

  context "conversations" do
    describe "GET" do
      before do
        @user_empty = FactoryGirl.create(:user)
        @user = FactoryGirl.create(:user)
        @c1 = FactoryGirl.create(:conversation, author: @user.person)
        @c2 = FactoryGirl.create(:conversation, author: @user.person)
      end

      it "fails if not logged in" do
        browser.get("/conversations")
        browser.follow_redirect!
        browser.last_response.should be_401
      end

      it "returns an empty array if the user has no conversations" do
        login_as(@user_empty)
        browser.get("/conversations")

        response.should be_json
        response.should be_successful
        parse_json(response.body).should eql []
      end

      it "returns the conversations as json" do
        login_as(@user)
        browser.get("/conversations")

        response.should be_json
        response.should be_successful
        parse_json(response.body).map { |c| c[:id] }.should include(@c1.id, @c2.id)
      end
    end

    describe "POST" do
      before do
        @create_hash = {
          contact_ids: [alice.contacts.pluck(:id)],
          conversation: {
            subject: "test subject",
            text: "test text test text", # this is not the actual text
            message: {
              text: "asdf test asdf text" # this is the actual text
            }
          }
        }
      end

      it "fails if not logged in" do
        browser.post("/conversations", {})
        browser.follow_redirect!
        browser.last_response.should be_401
      end

      it "fails if the params are incomplete" do
        login_as(alice)
        browser.post("/conversations", {not_a_conversation: true})
        response.should be_400
      end

      it "creates a conversation" do
        login_as(alice)
        lambda {
          browser.post("/conversations", @create_hash)
        }.should change(Conversation, :count).by(1)
        parse_json(response.body)[:subject].should eql("test subject")
      end

      it "creates a message" do
        login_as(alice)
        lambda {
          browser.post("/conversations", @create_hash)
        }.should change(Message, :count).by(1)
      end

      it "sets the author to the logged in user" do
        login_as(alice)
        browser.post("/conversations", @create_hash)
        parse_json(response.body)[:author][:id].should eql(alice.person.id)
      end

      it "dispatches the conversation" do
        login_as(alice)
        alice.should_receive(:dispatch!)
        browser.post("/conversations", @create_hash)
      end
    end

    describe "DELETE" do
      before do
        @conversation = FactoryGirl.create(:conversation_with_message, author: bob.person)
      end

      it "fails if not logged in" do
        lambda {
          browser.delete("/conversations/#{@conversation.id}/visibility")
        }.should_not change(ConversationVisibility, :count)
        browser.follow_redirect!
        browser.last_response.should be_401
      end

      it "deletes the visibility" do
        login_as(bob)
        lambda {
          browser.delete("/conversations/#{@conversation.id}/visibility")
        }.should change(ConversationVisibility, :count).by(-1)
        response.should be_successful
      end

      it "doesn't destroy other users visibilities" do
        login_as(alice)
        lambda {
          browser.delete("/conversations/#{@conversation.id}/visibility")
        }.should_not change(ConversationVisibility, :count)
        response.should_not be_successful
      end
    end

    context "messages" do
      describe "GET" do
        before do
          @conv_no_msg  = FactoryGirl.create(:conversation, author: bob.person)
          @conversation = FactoryGirl.create(:conversation_with_message, author: alice.person)
        end

        it "fails if not logged in" do
          browser.get("/conversations/#{@conversation.id}/messages")
          browser.follow_redirect!
          browser.last_response.should be_401
        end

        it "responds with 404 when a conversation can't be found" do
          login_as(eve)
          browser.get("/conversations/#{@conv_no_msg.id}/messsages")

          response.should be_404
          response.should be_json
        end

        it "returns an empty array if the users conversation has no messages" do
          login_as(bob)
          browser.get("/conversations/#{@conv_no_msg.id}/messages")

          response.should be_json
          response.should be_successful
          parse_json(response.body).should eql []
        end

        it "returns the messages as json" do
          login_as(alice)
          browser.get("/conversations/#{@conversation.id}/messages")

          response.should be_json
          response.should be_successful
          parse_json(response.body).map { |m| m[:id] }.should include(*@conversation.messages.pluck(:id))
        end
      end

      describe "POST" do
        before do
          @conv = FactoryGirl.create(:conversation, author: eve.person)
          @create_hash = { message: { text: "testing message text" } }
        end

        it "fails if not logged in" do
          browser.post("/conversations/#{@conv.id}/messages", {})
          browser.follow_redirect!
          browser.last_response.should be_401
        end

        it "responds with 404 when conversation can't be found" do
          login_as(alice)
          browser.post("/conversations/#{@conv.id}/messages", {})

          response.should be_404
          response.should be_json
        end

        it "fails if the params are incomplete" do
          login_as(eve)
          browser.post("/conversations/#{@conv.id}/messages", {not_a_message: true})
          response.should be_400
        end

        it "creates a message on one's own conversation" do
          login_as(eve)
          lambda {
            browser.post("/conversations/#{@conv.id}/messages", @create_hash)
          }.should change(@conv.messages, :count).by(1)
          parse_json(response.body)[:text].should eql("testing message text")
        end

        it "sets the author to the logged in user" do
          login_as(eve)
          browser.post("/conversations/#{@conv.id}/messages", @create_hash)
          parse_json(response.body)[:author][:id].should eql(eve.person.id)
        end

        it "dispatches the conversation" do
          login_as(eve)
          eve.should_receive(:dispatch!)
          browser.post("/conversations/#{@conv.id}/messages", @create_hash)
        end

        context "different user" do
          before do
            @conv.participants << bob.person
            @conv.save
          end

          it "creates a message on someone else's conversation" do
            login_as(bob)
            lambda {
              browser.post("/conversations/#{@conv.id}/messages", @create_hash)
            }.should change(@conv.messages, :count).by(1)
          end

          it "sets the other user's authorship" do
            login_as(bob)
            @create_hash[:message][:text] += " by bob"
            browser.post("/conversations/#{@conv.id}/messages", @create_hash)

            result = parse_json(response.body)
            result[:author][:id].should eql(bob.person.id)
            result[:text].should eql("testing message text by bob")
          end
        end
      end
    end
  end
end
