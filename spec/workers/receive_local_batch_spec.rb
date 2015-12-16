require "spec_helper"

describe Workers::ReceiveLocalBatch do
  it "calls the postzord" do
    post = double
    allow(Post).to receive(:find).with(1).and_return(post)

    zord = double
    expect(Postzord::Receiver::LocalBatch).to receive(:new).with(post, [2]).and_return(zord)
    expect(zord).to receive(:perform!)

    Workers::ReceiveLocalBatch.new.perform("Post", 1, [2])
  end
end
