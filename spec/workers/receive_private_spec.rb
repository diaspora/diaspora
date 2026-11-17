# frozen_string_literal: true

describe ReceivePrivateWorker do
  let(:data) { "<xml></xml>" }

  it "calls receive_private of federation gem" do
    rsa_key = double

    expect(OpenSSL::PKey::RSA).to receive(:new).with(alice.serialized_private_key).and_return(rsa_key)
    expect(DiasporaFederation::Federation::Receiver).to receive(:receive_private).with(data, rsa_key, alice.id)

    ReceivePrivateWorker.new.perform(alice.id, data)
  end

  it "filters errors that would also fail on second try" do
    rsa_key = double

    expect(OpenSSL::PKey::RSA).to receive(:new).with(alice.serialized_private_key).and_return(rsa_key)
    expect(DiasporaFederation::Federation::Receiver).to receive(:receive_private).with(
      data, rsa_key, alice.id
    ).and_raise(DiasporaFederation::Salmon::InvalidSignature)

    expect {
      ReceivePrivateWorker.new.perform(alice.id, data)
    }.not_to raise_error
  end

  it "does not filter errors that would succeed on second try" do
    rsa_key = double

    expect(OpenSSL::PKey::RSA).to receive(:new).with(alice.serialized_private_key).and_return(rsa_key)
    expect(DiasporaFederation::Federation::Receiver).to receive(:receive_private).with(
      data, rsa_key, alice.id
    ).and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)

    expect {
      ReceivePrivateWorker.new.perform(alice.id, data)
    }.to raise_error DiasporaFederation::Federation::Fetcher::NotFetchable
  end
end
