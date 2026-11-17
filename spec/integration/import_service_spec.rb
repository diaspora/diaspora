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

    it "skips photos that are already stored on this pod" do
      second_archive = Tempfile.new(%w[photos .zip])
      old_random_string = photo.random_string
      inlined_jobs { ImportService.new.import_by_files(nil, photo_archive.current_path, user.username) }
      imported_path = photo.reload.unprocessed_image.path
      expect(imported_path).to include(old_random_string)
      imported_digest = Digest::SHA256.file(imported_path).hexdigest

      Zip::OutputStream.open(second_archive.path) do |zip|
        zip.put_next_entry(photo.remote_photo_name)
        zip.write(Rails.root.join("spec/fixtures/exif.jpg").binread)
      end
      expect(Diaspora::Federation::Dispatcher).not_to receive(:build)

      inlined_jobs { ImportService.new.import_by_files(nil, second_archive.path, user.username) }

      expect(photo.reload.unprocessed_image.path).to eq(imported_path)
      expect(Digest::SHA256.file(imported_path).hexdigest).to eq(imported_digest)
    ensure
      FileUtils.rm_rf(second_archive.path.delete_suffix(".zip"))
      second_archive.close!
    end

    it "does not import photos of other people from reshared posts" do
      archive = Tempfile.new(%w[photos .zip])
      remote_post = FactoryBot.create(:status_message, author: FactoryBot.create(:person), public: true)
      remote_photo = FactoryBot.create(:remote_photo, author: remote_post.author, status_message: remote_post)
      remote_photo.update!(unprocessed_image: nil)
      FactoryBot.create(:reshare, root: remote_post, author: user.person)

      Zip::OutputStream.open(archive.path) do |zip|
        zip.put_next_entry(remote_photo.remote_photo_name)
        zip.write(Rails.root.join("spec/fixtures/button.png").binread)
      end

      expect {
        inlined_jobs { ImportService.new.import_by_files(nil, archive.path, user.username) }
      }.not_to(change { remote_photo.reload.attributes })
    ensure
      FileUtils.rm_rf(archive.path.delete_suffix(".zip"))
      archive.close!
    end

    it "does not extract entries with paths that escape the destination folder" do
      malicious_zip = Tempfile.new(%w[malicious .zip])
      Zip::OutputStream.open(malicious_zip.path) do |zip|
        zip.put_next_entry("../escaped.txt")
        zip.write("pawned mrowww")
      end

      destination = malicious_zip.path.delete_suffix(".zip")
      escaped_path = File.expand_path("../escaped.txt", destination)

      begin
        ImportService.new.send(:unzip_photos_file, malicious_zip.path)

        expect(File.exist?(escaped_path)).to be false
      ensure
        FileUtils.rm_rf(destination)
        FileUtils.rm_f(escaped_path)
        malicious_zip.close
        malicious_zip.unlink
      end
    end

    it "does not import files from outside the archive" do
      photo_archive_path = photo_archive.current_path
      outside_file = File.join(File.dirname(photo_archive_path), "outside.png")
      FileUtils.cp(Rails.root.join("spec/fixtures/button.png"), outside_file)
      photo.update!(remote_photo_name: "../outside.png")

      inlined_jobs { ImportService.new.import_by_files(nil, photo_archive_path, user.username) }

      imported_photo = photo.reload
      expect(imported_photo.unprocessed_image).to be_blank
      expect(imported_photo.remote_photo_path).to eq("https://old.example.com/uploads/images/")
    ensure
      FileUtils.rm_f(outside_file) if outside_file
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

    it "imports the photo with a new random name if a file with the same name already exists" do
      archive = Tempfile.new(%w[photos .zip])
      other_photo = FactoryBot.create(:photo)
      version_name = "thumb_small_#{other_photo.unprocessed_image_identifier}"
      version_path = other_photo.unprocessed_image.thumb_small.path
      version_digest = Digest::SHA256.file(version_path).hexdigest

      photo.update!(unprocessed_image: nil, random_string: nil, remote_photo_name: version_name,
                    remote_photo_path: "https://old.example.com/uploads/images/")
      Zip::OutputStream.open(archive.path) do |zip|
        zip.put_next_entry(version_name)
        zip.write(Rails.root.join("spec/fixtures/exif.jpg").binread)
      end

      dispatcher = double
      expect(Diaspora::Federation::Dispatcher).to receive(:build).with(user, photo).and_return(dispatcher)
      expect(dispatcher).to receive(:dispatch)

      inlined_jobs { ImportService.new.import_by_files(nil, archive.path, user.username) }

      expect(Digest::SHA256.file(version_path).hexdigest).to eq(version_digest)
      new_random_string = photo.reload.random_string
      expect(new_random_string).not_to include(other_photo.random_string)
      expect(photo.unprocessed_image.path).to include(new_random_string)
    ensure
      FileUtils.rm_rf(archive.path.delete_suffix(".zip"))
      archive.close!
    end
  end
end
