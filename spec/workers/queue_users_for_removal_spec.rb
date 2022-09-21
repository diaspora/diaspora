# frozen_string_literal: true

describe Workers::QueueUsersForRemoval do
  describe "remove_old_users is active" do
    before do
      AppConfig.settings.maintenance.remove_old_users.enable = true
      AppConfig.settings.maintenance.remove_old_users.limit_removals_to_per_day = 1
      ActionMailer::Base.deliveries = nil
      Timecop.freeze
    end

    it "#does not queue user that is not inactive" do
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 728.days, sign_in_count: 5)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after).to eq(nil)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "#queues user that is inactive" do
      removal_date = Time.zone.now + AppConfig.settings.maintenance.remove_old_users.warn_days.to_i.days
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 732.days, sign_in_count: 5)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after.to_i).to be_within(1.day).of(removal_date.utc.to_i)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "#queues user that is inactive and has not logged in" do
      removal_date = Time.zone.now
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 735.days, sign_in_count: 0)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after.to_i).to be_within(1.day).of(removal_date.utc.to_i)
      expect(ActionMailer::Base.deliveries.count).to eq(0) # no email sent
    end

    it "#does not queue user that is not inactive and has not logged in" do
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 728.days, sign_in_count: 0)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after).to eq(nil)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "#does not queue user that has already been flagged for removal" do
      removal_date = Time.zone.today + 5.days
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 735.days, sign_in_count: 5, remove_after: removal_date)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after).to eq(removal_date)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "#does not queue more warnings than has been configured as limit" do
      FactoryBot.create(:user, last_seen: Time.zone.now - 735.days, sign_in_count: 1)
      FactoryBot.create(:user, last_seen: Time.zone.now - 735.days, sign_in_count: 1)
      Workers::QueueUsersForRemoval.new.perform
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    after do
      Timecop.return
    end
  end

  describe "remove_old_users is inactive" do
    before do
      AppConfig.settings.maintenance.remove_old_users.enable = false
      ActionMailer::Base.deliveries = nil
    end

    it "#does not queue user that is not inactive" do
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 728.days, sign_in_count: 5)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after).to eq(nil)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    it "#does not queue user that is inactive" do
      user = FactoryBot.create(:user, last_seen: Time.zone.now - 735.days, sign_in_count: 5)
      Workers::QueueUsersForRemoval.new.perform
      user.reload
      expect(user.remove_after).to eq(nil)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
