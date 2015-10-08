require "spec_helper"

describe Workers::DatabaseSizeControl do
  describe "database size control is active" do
    before do
      AppConfig.settings.maintenance.database_size_control.enable = true
      AppConfig.settings.maintenance.database_size_control.remove_old_participations_after = 1
    end

    it "#removes signatures from likes older than set time" do
      like = FactoryGirl.create(
        :like, created_at: 2.days.ago, author_signature: "foobar", parent_author_signature: "barfoo"
      )
      like2 = FactoryGirl.create(
        :like, created_at: Time.zone.today, author_signature: "foobar", parent_author_signature: "barfoo"
      )
      Workers::DatabaseSizeControl.new.perform
      like = Like.find(like.id)
      like2 = Like.find(like2.id)
      expect(like.author_signature).to be_nil
      expect(like2.author_signature).to eq("foobar")
      expect(like.parent_author_signature).to be_nil
      expect(like2.parent_author_signature).to eq("barfoo")
    end
  end
end

describe Workers::DatabaseSizeControl do
  describe "database size control is inactive" do
    before do
      AppConfig.settings.maintenance.database_size_control.enable = false
      AppConfig.settings.maintenance.database_size_control.remove_old_participations_after = 1
    end

    it "#does not remove any signatures" do
      like = FactoryGirl.create(
        :like, created_at: 2.days.ago, author_signature: "foobar", parent_author_signature: "barfoo"
      )
      Workers::DatabaseSizeControl.new.perform
      like = Like.find(like.id)
      expect(like.author_signature).to eq("foobar")
      expect(like.parent_author_signature).to eq("barfoo")
    end
  end
end
