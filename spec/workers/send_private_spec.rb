# frozen_string_literal: true

describe SendPrivateWorker do
  let(:sender_id) { "any_user@example.org" }
  let(:obj_str) { "status_message@guid" }
  let(:targets) {
    {
      "https://example.org/receive/user/guid" => "<xml>post</xml>",
      "https://example.com/receive/user/guid" => "<xml>post2</xml>"
    }
  }
  let(:failing_targets) { {"https://example.org/receive/user/guid" => "<xml>post</xml>"} }

  it "succeeds if all urls were successful" do
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return({})
    expect(SendPrivateWorker).not_to receive(:perform_in)

    SendPrivateWorker.new.perform(sender_id, obj_str, targets)
  end

  it "retries failing urls" do
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return(failing_targets)
    expect(SendPrivateWorker).to receive(:perform_in).with(
      kind_of(Integer), sender_id, obj_str, failing_targets, 1
    )

    SendPrivateWorker.new.perform(sender_id, obj_str, targets)
  end

  it "does not retry failing urls if max retries is reached" do
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return(failing_targets)
    expect(SendPrivateWorker).not_to receive(:perform_in)

    expect {
      SendPrivateWorker.new.perform(sender_id, obj_str, targets, 9)
    }.to raise_error SendBaseWorker::MaxRetriesReached
  end

  it "retries contact entities 20 times" do
    contact = Fabricate(:contact_entity, author: sender_id, recipient: alice.diaspora_handle)
    obj_str = contact.to_s
    targets = {"https://example.org/receive/user/guid" => "<xml>post</xml>"}
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return(targets).twice

    expect(SendPrivateWorker).to receive(:perform_in).with(a_kind_of(Numeric), sender_id, obj_str, targets, 19)
    SendPrivateWorker.new.perform(sender_id, obj_str, targets, 18)

    expect(SendPrivateWorker).not_to receive(:perform_in)
    expect {
      SendPrivateWorker.new.perform(sender_id, obj_str, targets, 19)
    }.to raise_error SendBaseWorker::MaxRetriesReached
  end
end
