# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::AuthorPrivateKeyValidator do
  include_context "validators shared context"

  context "when private key doesn't match the key in the archive" do
    let(:author) { FactoryGirl.create(:person) }

    it "contains error" do
      expect(validator.messages)
        .to include("Private key in the archive doesn't match the known key of #{author_id}")
    end
  end

  context "when private key matches the key in the archive" do
    let(:author) { FactoryGirl.create(:person, serialized_public_key: author_pkey.public_key.export) }

    include_examples "validation result is valid"
  end

  context "with non-fetchable author" do
    let(:author_id) { "old_id@old_pod.nowhere" }

    before do
      stub_request(:get, %r{https*://old_pod\.nowhere/\.well-known/webfinger\?resource=acct:old_id@old_pod\.nowhere})
        .to_return(status: 404, body: "", headers: {})
      stub_request(:get, %r{https*://old_pod\.nowhere/\.well-known/host-meta})
        .to_return(status: 404, body: "", headers: {})
    end

    include_examples "validation result is valid"
  end
end
