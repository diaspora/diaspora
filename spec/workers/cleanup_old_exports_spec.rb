# frozen_string_literal: true

describe Workers::CleanupOldExports do
  let(:user) { FactoryGirl.create(:user) }

  context "with profile data" do
    before do
      user.perform_export!
    end

    it "removes old archives" do
      Timecop.travel(Time.zone.today + 15.days) do
        Workers::CleanupOldExports.new.perform
        user.reload
        expect(user.export).not_to be_present
        expect(user.exported_at).to be_nil
      end
    end

    it "does not remove new archives" do
      Timecop.travel(Time.zone.today + 1.day) do
        Workers::CleanupOldExports.new.perform
        user.reload
        expect(user.export).to be_present
        expect(user.exported_at).to be_present
      end
    end
  end

  context "with photos" do
    before do
      user.perform_export_photos!
    end

    it "removes old archives" do
      Timecop.travel(Time.zone.today + 15.days) do
        Workers::CleanupOldExports.new.perform
        user.reload
        expect(user.exported_photos_file).not_to be_present
        expect(user.exported_photos_at).to be_nil
      end
    end

    it "does not remove new archives" do
      Timecop.travel(Time.zone.today + 1.day) do
        Workers::CleanupOldExports.new.perform
        user.reload
        expect(user.exported_photos_file).to be_present
        expect(user.exported_photos_at).to be_present
      end
    end
  end
end
