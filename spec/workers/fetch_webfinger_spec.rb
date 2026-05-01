# frozen_string_literal: true

describe FetchWebfingerWorker do
  it "should webfinger and queue a job to fetch public posts" do
    @person = FactoryBot.create(:person)
    allow(Person).to receive(:find_or_fetch_by_identifier).and_return(@person)

    expect(Diaspora::Fetcher::Public).to receive(:queue_for).exactly(1).times

    FetchWebfingerWorker.new.perform(@person.diaspora_handle)
  end

  it "should webfinger and queue no job to fetch public posts if the person is not found" do
    allow(Person).to receive(:find_or_fetch_by_identifier).and_raise DiasporaFederation::Discovery::DiscoveryError

    expect(Diaspora::Fetcher::Public).not_to receive(:queue_for)

    FetchWebfingerWorker.new.perform("unknown-person@example.net")
  end
end
