# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::CollectionValidator do
  include_context "validators shared context"

  class TestValidator < ArchiveValidator::BaseValidator
    def initialize(_archive_hash, item)
      super({})
      self.valid = item
      messages.push("This element is invalid!") unless item
    end
  end

  class TestCollectionValidator < ArchiveValidator::CollectionValidator
    def initialize(collection)
      @collection = collection
      super({})
    end

    def entity_validator
      TestValidator
    end

    attr_reader :collection
  end

  it "validates when all collection elements are validated" do
    validator = TestCollectionValidator.new([true, true, true])
    expect(validator.collection).to eq([true, true, true])
    expect(validator.messages).to be_empty
  end

  it "removes invalid elements from the collection and add keeps failure messages" do
    validator = TestCollectionValidator.new([true, false, true])
    expect(validator.collection).to eq([true, true])
    expect(validator.messages).to eq(["This element is invalid!"])
  end
end
