# frozen_string_literal: true

shared_examples_for "a reference source" do
  let!(:source) { FactoryGirl.create(described_class.to_s.underscore.to_sym) }
  let!(:reference) { FactoryGirl.create(:reference, source: source) }

  describe "references" do
    it "returns the references" do
      expect(source.references).to match_array([reference])
    end

    it "destroys the reference when the source is destroyed" do
      source.destroy
      expect(Reference.where(id: reference.id)).not_to exist
    end
  end

  describe "#create_references" do
    it "creates a reference for every referenced post after create" do
      target1 = FactoryGirl.create(:status_message)
      target2 = FactoryGirl.create(:status_message)
      text = "Have a look at [this post](diaspora://#{target1.diaspora_handle}/post/#{target1.guid}) and " \
             "this one too diaspora://#{target2.diaspora_handle}/post/#{target2.guid}."

      post = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text)
      post.save

      expect(post.references.map(&:target).map(&:guid)).to match_array([target1, target2].map(&:guid))
    end

    it "ignores a reference with a unknown guid" do
      text = "Try this: `diaspora://unknown@localhost:3000/post/thislookslikeavalidguid123456789`"

      post = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text)
      post.save

      expect(post.references).to be_empty
    end

    it "ignores a reference with an invalid entity type" do
      target = FactoryGirl.create(:status_message)

      text = "Try this: `diaspora://#{target.diaspora_handle}/posts/#{target.guid}`"

      post = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text)
      post.save

      expect(post.references).to be_empty
    end

    it "only creates one reference, even when it is referenced twice" do
      target = FactoryGirl.create(:status_message)
      text = "Have a look at [this post](diaspora://#{target.diaspora_handle}/post/#{target.guid}) and " \
             "this one too diaspora://#{target.diaspora_handle}/post/#{target.guid}."

      post = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text)
      post.save

      expect(post.references.map(&:target).map(&:guid)).to match_array([target.guid])
    end

    it "only creates references, when the author of the known entity matches" do
      target1 = FactoryGirl.create(:status_message)
      target2 = FactoryGirl.create(:status_message)
      text = "Have a look at [this post](diaspora://#{target1.diaspora_handle}/post/#{target1.guid}) and " \
             "this one too diaspora://#{target1.diaspora_handle}/post/#{target2.guid}."

      post = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text)
      post.save

      expect(post.references.map(&:target).map(&:guid)).to match_array([target1.guid])
    end
  end
end

shared_examples_for "a reference target" do
  let!(:target) { FactoryGirl.create(described_class.to_s.underscore.to_sym) }
  let!(:reference) { FactoryGirl.create(:reference, target: target) }

  describe "referenced_by" do
    it "returns the references where the target is referenced" do
      expect(target.referenced_by).to match_array([reference])
    end

    it "destroys the reference when the target is destroyed" do
      target.destroy
      expect(Reference.where(id: reference.id)).not_to exist
    end
  end
end
