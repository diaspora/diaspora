require "spec_helper"
require "federation-testbed"

describe "Generation and dispatch of federation messages" do
  before :all do
    @testbed_pod = FactoryGirl.create(:pod)
    FederationTestbed.config.configure(
      "testbed_config" => {"host" => @testbed_pod.host, "method" => "http"},
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
    stub_request(:any, Addressable::Template.new(@testbed_pod.host + "/.well-known/host-meta")).to_rack(rack_app)
    stub_request(:any, Addressable::Template.new(@testbed_pod.host + "/webfinger?q=acct:test@" + @testbed_pod.host))
      .to_rack(rack_app)
    stub_request(:any, Addressable::Template.new(@testbed_pod.host + "/hcard/users/test@" + @testbed_pod.host))
      .to_rack(rack_app)
    stub_request(:any, Addressable::Template.new(@testbed_pod.host + "/receive/users/{guid}")).to_rack(rack_app)
  end
  after :all do
  end

  describe "user share request" do
    it "works" do
      friend = Person.find_or_fetch_by_identifier("test@" + @testbed_pod.host)
      expect(friend).not_to be_nil
      allow_any_instance_of(Postzord::Dispatcher::Private).to receive(:deliver_to_remote).and_call_original
      allow_any_instance_of(Postzord::Dispatcher::Public).to receive(:deliver_to_remote).and_call_original
      expect(alice.share_with(friend, alice.aspects.first)).not_to be_falsy
    end
  end
end
