# frozen_string_literal: true

describe SendPublicWorker do
  let(:sender_id) { "any_user@example.org" }
  let(:obj_str) { "status_message@guid" }
  let(:urls) { ["https://example.org/receive/public", "https://example.com/receive/public"] }
  let(:xml) { "<xml>post</xml>" }

  it "succeeds if all urls were successful" do
    expect(DiasporaFederation::Federation::Sender).to receive(:public).with(
      sender_id, obj_str, urls, xml
    ).and_return([])
    expect(SendPublicWorker).not_to receive(:perform_in)

    SendPublicWorker.new.perform(sender_id, obj_str, urls, xml)
  end

  it "retries failing urls" do
    failing_urls = [urls.at(0)]
    expect(DiasporaFederation::Federation::Sender).to receive(:public).with(
      sender_id, obj_str, urls, xml
    ).and_return(failing_urls)
    expect(SendPublicWorker).to receive(:perform_in).with(
      kind_of(Integer), sender_id, obj_str, failing_urls, xml, 1
    )

    SendPublicWorker.new.perform(sender_id, obj_str, urls, xml)
  end

  it "does not retry failing urls if max retries is reached" do
    failing_urls = [urls.at(0)]
    expect(DiasporaFederation::Federation::Sender).to receive(:public).with(
      sender_id, obj_str, urls, xml
    ).and_return(failing_urls)
    expect(SendPublicWorker).not_to receive(:perform_in)

    expect {
      SendPublicWorker.new.perform(sender_id, obj_str, urls, xml, 9)
    }.to raise_error SendBaseWorker::MaxRetriesReached
  end
end
