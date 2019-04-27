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
    context "with the default key format" do
      let(:author_pkey) { OpenSSL::PKey::RSA.generate(512) }
      let(:archive_private_key) { author_pkey.export }

      let(:author) { FactoryGirl.create(:person, serialized_public_key: author_pkey.public_key.export) }

      include_examples "validation result is valid"
    end

    context "when key is serialized in pub1 in the DB" do
      let(:archive_private_key) { <<~RSA }
        -----BEGIN RSA PRIVATE KEY-----
        MIIBOgIBAAJBANswwmiaCy9vleC5L5StCe8+urb/UKQwYpheWA+BFSKf9VLBTbgL
        wWMcgoGUqLaS6RrhcGVxml6vKe20lLFpxOECAwEAAQJBAM6RdjXkLvRmgeZGP/wq
        03kAMjDyDsqdut2D1BPQf92fCUCh8N000rsiWqZLKf6qz2X6qVeRRnU4JdpHrC03
        2z0CIQD3x6hhwGWUjnqEQm/pBtRNrrat0h/LpTNx55wn4JhNswIhAOJ2TCzb5GX0
        mQQooR1WJ2OqoUxM66C/XdJRL5r/lKEbAiB0Er8Jk+TCNACm5qygQEfCYF9JjE7C
        ypAQAwz/DVKrywIgL0//wi9+nD5p6ZCDeJmTSSNQ55v6bm8Mru//Pia/apkCID3y
        m/nJS0EGyGd2SV0gfnawS5llnX9psqIKvBa8mOQ/
        -----END RSA PRIVATE KEY-----
      RSA

      let(:author) {
        FactoryGirl.create(:person, serialized_public_key: <<~RSA)
          -----BEGIN RSA PUBLIC KEY-----
          MEgCQQDbMMJomgsvb5XguS+UrQnvPrq2/1CkMGKYXlgPgRUin/VSwU24C8FjHIKB
          lKi2kuka4XBlcZperynttJSxacThAgMBAAE=
          -----END RSA PUBLIC KEY-----
        RSA
      }

      include_examples "validation result is valid"
    end
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
