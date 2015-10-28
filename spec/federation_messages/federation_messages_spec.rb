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
    u = FederationTestbed::User.new
    u.id = alice.diaspora_handle
    u.public_key = alice.public_key
    u.private_key = nil
    FederationTestbed.test_data.push(u)
    rack_app = FederationTestbed::App.new
    stub_request(:get, Addressable::Template.new(@testbed_pod + "/.well-known/host-meta")).to_rack(rack_app)
    stub_request(:get, Addressable::Template.new(@testbed_pod + "/webfinger?q=acct:test@" + @testbed_pod))
      .to_rack(rack_app)
    stub_request(:get, Addressable::Template.new(@testbed_pod + "/hcard/users/test@" + @testbed_pod))
      .to_rack(rack_app)
    stub_request(:post, Addressable::Template.new(@testbed_pod + "/receive/users/{guid}")).to_rack(rack_app)
  end
  before do
    allow_any_instance_of(Postzord::Dispatcher::Private).to receive(:deliver_to_remote).and_call_original
    allow_any_instance_of(Postzord::Dispatcher::Public).to receive(:deliver_to_remote).and_call_original
  end
  after :all do
  end

  describe "user share request" do
    it "works" do
      friend = Person.find_or_fetch_by_identifier("test@" + @testbed_pod)
      expect(friend).not_to be_nil
      expect(alice.share_with(friend, alice.aspects.first)).not_to be_falsy
    end
  end
end
