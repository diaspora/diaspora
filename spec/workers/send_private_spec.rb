# frozen_string_literal: true

describe Workers::SendPrivate do
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
    expect(Workers::SendPrivate).not_to receive(:perform_in)

    Workers::SendPrivate.new.perform(sender_id, obj_str, targets)
  end

  it "retries failing urls" do
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return(failing_targets)
    expect(Workers::SendPrivate).to receive(:perform_in).with(
      kind_of(Integer), sender_id, obj_str, failing_targets, 1
    )

    Workers::SendPrivate.new.perform(sender_id, obj_str, targets)
  end

  it "does not retry failing urls if max retries is reached" do
    expect(DiasporaFederation::Federation::Sender).to receive(:private).with(
      sender_id, obj_str, targets
    ).and_return(failing_targets)
    expect(Workers::SendPrivate).not_to receive(:perform_in)

    expect {
      Workers::SendPrivate.new.perform(sender_id, obj_str, targets, 9)
    }.to raise_error Workers::SendBase::MaxRetriesReached
  end
end
