
require "spec_helper"
require Rails.root.join("db/migrate/20150828132451_remove_duplicate_and_empty_pods.rb")

describe RemoveDuplicateAndEmptyPods do
  self.use_transactional_fixtures = false

  before do
    @previous_migration = 20_150_731_123_114
    @my_migration = 20_150_828_132_451
    Pod.delete_all
  end

  after :all do
    migrate_to(nil) # up
    Pod.delete_all # cleanup manually, transactions are disabled
  end

  def migrate_to(version)
    ActiveRecord::Migrator.migrate(Rails.root.join("db", "migrate"), version)
  end

  describe "#up" do
    before do
      migrate_to(@previous_migration)

      FactoryGirl.create(:pod, host: nil)
      FactoryGirl.create(:pod, host: "")
      4.times { FactoryGirl.create(:pod, host: "aaa.aa") }
    end

    it "removes duplicates" do
      expect(Pod.where(host: "aaa.aa").count).to eql(4)
      migrate_to(@my_migration)
      expect(Pod.where(host: "aaa.aa").count).to eql(1)
    end

    it "removes empty hostnames" do
      expect(Pod.where(host: [nil, ""]).count).to eql(2)
      migrate_to(@my_migration)
      expect(Pod.where(host: [nil, ""]).count).to eql(0)
    end

    it "adds an index on the host column" do
      expect {
        migrate_to(@my_migration)
        Pod.reset_column_information
      }.to change { Pod.connection.indexes(Pod.table_name).count }.by(1)
    end
  end

  describe "#down" do
    before do
      migrate_to(@my_migration)
    end

    it "removes the index on the host column" do
      expect {
        migrate_to(@previous_migration)
        Pod.reset_column_information
      }.to change { Pod.connection.indexes(Pod.table_name).count }.by(-1)
    end
  end
end
