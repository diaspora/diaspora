require "spec_helper"
require "federation-testbed"

describe "Generation and dispatch of federation messages" do
  before :all do
    @testbed_pod = FactoryGirl.build(:pod).host
    FederationTestbed.config.configure(
      "testbed_config" => {"host" => @testbed_pod, "method" => "http"},
      "test_target"    => {
        "method" => "http",
        "host"   => "localhost:3000",
        "user"   => "alice"
      }
    )
    user = FederationTestbed::User.new
    user.id = alice.diaspora_handle
    user.public_key = alice.public_key
    user.private_key = nil
    FederationTestbed.test_data.push(user)
    @rack_app = FederationTestbed::App.new!
    stub_request(:get, Addressable::Template.new("#{@testbed_pod}/.well-known/host-meta"))
      .to_rack(@rack_app)
    stub_request(:get, Addressable::Template.new("#{@testbed_pod}/webfinger?q=acct:test@#{@testbed_pod}"))
      .to_rack(@rack_app)
    stub_request(:get, Addressable::Template.new("#{@testbed_pod}/hcard/users/test@#{@testbed_pod}"))
      .to_rack(@rack_app)
    stub_request(:post, Addressable::Template.new("#{@testbed_pod}/receive/users/{guid}"))
      .to_rack(@rack_app)
  end

  before do
    allow_any_instance_of(Postzord::Dispatcher::Private).to receive(:deliver_to_remote).and_call_original
    allow_any_instance_of(Postzord::Dispatcher::Public).to receive(:deliver_to_remote).and_call_original
    @rack_app.pulled_entities.clear
  end

  describe "user share request" do
    it "works" do
      friend = Person.find_or_fetch_by_identifier("test@#{@testbed_pod}")
      expect(friend).not_to be_nil
      expect(alice.share_with(friend, alice.aspects.first)).not_to be_falsy
      expect(@rack_app.pulled_entities.length).to eq(2)
      expect(@rack_app.pulled_entities[0].sender_id).to eq(alice.diaspora_handle)
      expect(@rack_app.pulled_entities[0].recipient_id).to eq(friend.diaspora_handle)
      expect(@rack_app.pulled_entities[1].diaspora_id).to eq(alice.diaspora_handle) # profile is pushed after sharing is requested
    end
  end
end
