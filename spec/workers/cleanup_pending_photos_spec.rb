# frozen_string_literal: true

describe Workers::CleanupPendingPhotos do
  let!(:photo) { FactoryGirl.create(:photo, author: alice.person, pending: true) }

  it "removes pending photos" do
    Timecop.travel(25.hours) do
      Workers::CleanupPendingPhotos.new.perform
      expect(Photo).not_to exist(photo.id)
    end
  end

  it "does not remove pending photos newer than one day" do
    Timecop.travel(1.hour) do
      Workers::CleanupPendingPhotos.new.perform
      expect(Photo).to exist(photo.id)
    end
  end

  it "does not remove posted photos" do
    StatusMessageCreationService.new(alice).create(
      status_message: {text: "Post with photo"},
      public:         true,
      photos:         [photo.id]
    )
    Timecop.travel(25.hours) do
      Workers::CleanupPendingPhotos.new.perform
      expect(Photo).to exist(photo.id)
    end
  end
end
