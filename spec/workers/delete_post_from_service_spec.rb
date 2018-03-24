# frozen_string_literal: true

describe Workers::DeletePostFromService do
  it "calls service#delete_from_service with given opts" do
    service = double
    opts = {facebook_id: "23456"}

    expect(service).to receive(:delete_from_service).with(opts)
    allow(Service).to receive(:find_by_id).with("123").and_return(service)

    Workers::DeletePostFromService.new.perform("123", opts)
  end
end
