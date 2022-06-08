# frozen_string_literal: true

describe ImportService do
  context "import photos archive" do
    let(:user) { FactoryBot.create(:user) }
    let(:photo) { FactoryBot.create(:status_message_with_photo, author: user.person).photos.first }
    let(:photo_archive) {
      user.perform_export_photos!
      photo_archive = user.exported_photos_file

      # cleanup photo after creating the archive, so it's like it was imported from a remote pod
      photo.unprocessed_image = nil
      photo.random_string = nil
      photo.remote_photo_path = "https://old.example.com/uploads/images/"
      photo.save

      photo_archive
    }

    it "imports the photo with the same name" do
      old_random_string = photo.random_string

      inlined_jobs { ImportService.new.import_by_files(nil, photo_archive.current_path, user.username) }

      imported_photo = photo.reload
      expect(imported_photo.random_string).to include(old_random_string)
      expect(imported_photo.unprocessed_image.path).to include(old_random_string)
      expect(imported_photo.processed_image.path).to include(old_random_string)
      expect(imported_photo.remote_photo_name).to include(old_random_string)
      expect(imported_photo.remote_photo_path).to eq("#{AppConfig.pod_uri}uploads/images/")
    end

    it "imports the photo with a new random name if a conflicting photo already exists" do
      old_random_string = photo.random_string
      photo_archive_path = photo_archive.current_path

      sm = FactoryBot.create(:status_message)
      FactoryBot.create(:photo, author: sm.author, status_message: sm, random_string: old_random_string)

      expect(Diaspora::Federation::Dispatcher).to receive(:build) do |user_param, photo_param|
        expect(user_param).to eq(user)
        expect(photo_param.id).to eq(photo.id)

        dispatcher = double
        expect(dispatcher).to receive(:dispatch)
        dispatcher
      end

      inlined_jobs { ImportService.new.import_by_files(nil, photo_archive_path, user.username) }

      imported_photo = photo.reload
      new_random_string = imported_photo.random_string
      expect(new_random_string).not_to include(old_random_string)
      expect(imported_photo.unprocessed_image.path).to include(new_random_string)
      expect(imported_photo.processed_image.path).to include(new_random_string)
      expect(imported_photo.remote_photo_name).to include(new_random_string)
      expect(imported_photo.remote_photo_path).to eq("#{AppConfig.pod_uri}uploads/images/")
    end
  end
end
