# frozen_string_literal: true

describe TagFollowingService do
  before do
    add_tag("tag1", alice)
    add_tag("tag2", alice)
  end

  describe "#create" do
    it "Creates new tag with valid name" do
      name = SecureRandom.uuid
      expect(alice.followed_tags.find_by(name: name)).to be_nil
      tag_data = tag_following_service(alice).create(name)
      expect(alice.followed_tags.find_by(name: name).name).to eq(name)
      expect(tag_data["name"]).to eq(name)
      expect(tag_data["id"]).to be_truthy
      expect(tag_data["taggings_count"]).to eq(0)
    end

    it "Throws error with empty tag" do
      expect { tag_following_service(alice).create(nil) }.to raise_error(ArgumentError)
      expect { tag_following_service(alice).create("") }.to raise_error(ArgumentError)
      expect { tag_following_service(alice).create("#") }.to raise_error(ArgumentError)
      expect { tag_following_service(alice).create(" ") }.to raise_error(ArgumentError)
    end

    it "throws an error when trying to follow an already followed tag" do
      name = SecureRandom.uuid
      tag_following_service.create(name)
      expect {
        tag_following_service.create(name)
      }.to raise_error TagFollowingService::DuplicateTag
    end
  end

  describe "#destroy" do
    it "Deletes tag with valid name" do
      name = SecureRandom.uuid
      add_tag(name, alice)
      expect(alice.followed_tags.find_by(name: name).name).to eq(name)
      expect(tag_following_service(alice).destroy_by_name(name)).to be_truthy
      expect(alice.followed_tags.find_by(name: name)).to be_nil
    end

    it "Deletes tag with id" do
      name = SecureRandom.uuid
      new_tag = add_tag(name, alice)
      expect(alice.followed_tags.find_by(name: name).name).to eq(name)
      expect(tag_following_service(alice).destroy(new_tag.tag_id)).to be_truthy
      expect(alice.followed_tags.find_by(name: name)).to be_nil
    end

    it "Does nothing with tag that isn't already followed" do
      original_length = alice.followed_tags.length
      expect {
        tag_following_service(alice).destroy_by_name(SecureRandom.uuid)
      }.to raise_error ActiveRecord::RecordNotFound
      expect {
        tag_following_service(alice).destroy(-1)
      }.to raise_error ActiveRecord::RecordNotFound
      expect(alice.followed_tags.length).to eq(original_length)
    end

    it "Does nothing with empty tag name" do
      original_length = alice.followed_tags.length
      expect {
        tag_following_service(alice).destroy_by_name("")
      }.to raise_error ActiveRecord::RecordNotFound
      expect(alice.followed_tags.length).to eq(original_length)
    end
  end

  describe "#index" do
    it "Returns user's list of tags" do
      tags = tag_following_service(alice).index
      expect(tags.length).to eq(alice.followed_tags.length)
    end
  end

  private

  def tag_following_service(user=alice)
    TagFollowingService.new(user)
  end

  def add_tag(name, user)
    tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name)
    tag_following = user.tag_followings.new(tag_id: tag.id)
    tag_following.save
    tag_following
  end
end
