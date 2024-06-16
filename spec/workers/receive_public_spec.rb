# frozen_string_literal: true

describe Workers::ReceivePublic do
  let(:data) { "<xml></xml>" }

  it "calls receive_public of federation gem" do
    expect(DiasporaFederation::Federation::Receiver).to receive(:receive_public).with(data)

    Workers::ReceivePublic.new.perform(data)
  end

  it "filters errors that would also fail on second try" do
    expect(DiasporaFederation::Federation::Receiver)
      .to receive(:receive_public).with(data).and_raise(DiasporaFederation::Salmon::InvalidSignature)

    expect {
      Workers::ReceivePublic.new.perform(data)
    }.not_to raise_error
  end

  it "does not filter errors that would succeed on second try" do
    expect(DiasporaFederation::Federation::Receiver)
      .to receive(:receive_public).with(data).and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)

    expect {
      Workers::ReceivePublic.new.perform(data)
    }.to raise_error DiasporaFederation::Federation::Fetcher::NotFetchable
  end
end
