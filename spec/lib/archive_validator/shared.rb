# frozen_string_literal: true

require "integration/federation/federation_helper"

shared_context "validators shared context" do
  let(:author_id) { author.diaspora_handle }
  let(:archive_private_key) { OpenSSL::PKey::RSA.generate(512).export }
  let(:archive_hash) { base_archive_hash }
  let(:validator) { described_class.new(input_hash) }

  def input_hash
    Yajl::Parser.new.parse(json_file)
  end

  def json_file
    StringIO.new(json_string)
  end

  def json_string
    archive_hash.to_json
  end

  def base_archive_hash
    {
      user:        {
        profile: {
          entity_type: "profile",
          entity_data: {
            author: author_id
          }
        },
        username: "aaaa",
        email: "aaaa@aa.com",
        private_key: archive_private_key,
        contacts: [], contact_groups: [], posts: [], relayables: [], followed_tags: [], post_subscriptions: []
      },
      others_data: {relayables: []},
      version:     "2.0"
    }
  end

  def include_in_input_archive(hash)
    archive_hash.deep_merge!(hash)
  end
end

shared_context "with known author" do
  let(:author) { FactoryGirl.create(:person) }
end

shared_examples "validation result is valid" do
  it "is valid" do
    expect(validator.valid?).to be_truthy
    expect(validator.messages).to be_empty
  end
end

shared_context "relayable validator context" do
  let(:validator) { described_class.new(input_hash, relayable) }

  let(:relayable_author) {
    remote_user_on_pod_b.diaspora_handle
  }
  let(:relayable_attributes) {
    {
      author: relayable_author
    }
  }

  let(:relayable) {
    Fabricate(relayable_entity, relayable_attributes).to_json.as_json
  }

  let(:guid) {
    relayable["entity_data"]["guid"]
  }

  let(:parent_guid) {
    relayable["entity_data"]["parent_guid"]
  }
end

shared_examples "a relayable validator" do
  context "with a correct comment" do
    include_examples "validation result is valid"
  end

  context "when the comment is already known" do
    let!(:original_comment) {
      FactoryGirl.create(:comment, guid: guid, author: Person.by_account_identifier(relayable_author))
    }

    include_examples "validation result is valid"
  end
end

shared_examples "a collection validator" do
  context "with correct elements in the collection" do
    before do
      include_in_input_archive(correct_archive)
    end

    include_examples "validation result is valid"
  end

  context "with incorrect elements in the collection" do
    before do
      include_in_input_archive(archive_with_error)
    end

    it "filters collection from invalid elements" do
      expect(validator.valid?).to be_falsey
      expect(validator.messages).to eq(element_validator_class.new(input_hash, incorrect_item).messages)
      expect(validator.collection).to eq([correct_item])
    end
  end
end
