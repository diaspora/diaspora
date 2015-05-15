require "spec_helper"

describe Workers::FetchWebfinger do
  it "should webfinger and queue a job to fetch public posts" do
    @person = FactoryGirl.create(:person)
    allow(Webfinger).to receive(:new).and_return(double(fetch: @person))

    expect(Diaspora::Fetcher::Public).to receive(:queue_for).exactly(1).times

    Workers::FetchWebfinger.new.perform(@person.diaspora_handle)
  end

  it "should webfinger and queue no job to fetch public posts if the person is not found" do
    allow(Webfinger).to receive(:new).and_return(double(fetch: nil))

    expect(Diaspora::Fetcher::Public).not_to receive(:queue_for)

    Workers::FetchWebfinger.new.perform("unknown-person@example.net")
  end
end
