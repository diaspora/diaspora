# frozen_string_literal: true

describe DiasporaLinkService do
  let(:service) { described_class.new(link) }

  describe "#find_or_fetch_entity" do
    context "when entity is known" do
      let(:post) { FactoryGirl.create(:status_message) }
      let(:link) { "diaspora://#{post.author.diaspora_handle}/post/#{post.guid}" }

      it "returns the entity" do
        expect(service.find_or_fetch_entity).to eq(post)
      end
    end

    context "when entity is unknown" do
      let(:remote_person) { FactoryGirl.create(:person) }
      let(:guid) { "1234567890abcdef" }
      let(:link) { "diaspora://#{remote_person.diaspora_handle}/post/#{guid}" }

      it "fetches entity" do
        expect(DiasporaFederation::Federation::Fetcher)
          .to receive(:fetch_public)
            .with(remote_person.diaspora_handle, "post", guid) {
              FactoryGirl.create(:status_message, author: remote_person, guid: guid)
            }

        entity = service.find_or_fetch_entity
        expect(entity).to be_a(StatusMessage)
        expect(entity.guid).to eq(guid)
        expect(entity.author).to eq(remote_person)
      end

      it "returns nil when entity is non fetchable" do
        expect(DiasporaFederation::Federation::Fetcher)
          .to receive(:fetch_public)
          .with(remote_person.diaspora_handle, "post", guid)
          .and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)

        expect(service.find_or_fetch_entity).to be_nil
      end
    end

    context "with invalid links" do
      it "returns nil when the link is invalid" do
        service = described_class.new("web+diaspora://something_invalid")
        expect(service.find_or_fetch_entity).to be_nil
      end

      it "returns nil when the author is valid, but rest of the link is invalid" do
        service = described_class.new("web+diaspora://#{alice.diaspora_handle}/foo/bar")
        expect(service.find_or_fetch_entity).to be_nil
      end
    end

    context "with only a diaspora ID" do
      let(:person) { FactoryGirl.create(:person) }
      let(:link) { "diaspora://#{person.diaspora_handle}" }

      it "returns the person" do
        expect(service.find_or_fetch_entity).to eq(person)
      end

      it "returns nil when person is non fetchable" do
        expect(Person).to receive(:find_or_fetch_by_identifier)
          .with(person.diaspora_handle).and_raise(DiasporaFederation::Discovery::DiscoveryError)

        expect(service.find_or_fetch_entity).to be_nil
      end
    end
  end
end
