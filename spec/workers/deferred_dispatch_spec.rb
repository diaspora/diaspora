require 'spec_helper'

describe Workers::DeferredDispatch do
  it "handles non existing records gracefully" do
    expect {
      described_class.new.perform(alice.id, "Comment", 0, {})
    }.to_not raise_error
  end

  describe "#social relay functionality" do
    let(:message) { FactoryGirl.create(:status_message, author: alice.person, public: true) }
    before do
      AppConfig.relay.outbound.send = true
    end

    it "triggers fetch of relay handle" do
      allow(Person).to receive(:find_by).and_return(nil)

      expect(Workers::FetchWebfinger).to receive(:perform_async)

      described_class.new.perform(alice.id, "StatusMessage", message.id, {})
    end

    it "triggers post to relay" do
      relay_person = FactoryGirl.create(:person, diaspora_handle: AppConfig.relay.outbound.handle)
      opts = {"additional_subscribers" => [relay_person], "services" => []}
      allow(Person).to receive(:find_by).and_return(relay_person)
      postzord = double
      allow(Postzord::Dispatcher).to receive(:build).with(any_args).and_return(postzord)
      allow(postzord).to receive(:post)
      allow(Person).to receive(:where).and_return([relay_person])

      expect(Postzord::Dispatcher).to receive(:build).with(alice, message, opts)

      described_class.new.perform(alice.id, "StatusMessage", message.id, {})
    end
  end
end
