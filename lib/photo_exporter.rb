# frozen_string_literal: true

class PhotoExporter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def perform
    temp_zip = Tempfile.new([user.username, "_photos.zip"])
    begin
      Zip::OutputStream.open(temp_zip.path) do |zip_output_stream|
        user.photos.each do |photo|
          export_photo(zip_output_stream, photo)
        end
      end
    ensure
      temp_zip.close
    end

    update_exported_photos_at(temp_zip)
  end

  private

  def export_photo(zip_output_stream, photo)
    photo_file = photo.unprocessed_image.file
    if photo_file
      photo_data = photo_file.read
      zip_output_stream.put_next_entry(photo.remote_photo_name)
      zip_output_stream.print(photo_data)
    else
      user.logger.info "Export photos error: No file for #{photo.remote_photo_name} not found"
    end
  rescue Errno::ENOENT
    user.logger.info "Export photos error: #{photo.unprocessed_image.file.path} not found"
  end

  def update_exported_photos_at(temp_zip)
    user.update exported_photos_file: temp_zip, exported_photos_at: Time.zone.now
  ensure
    user.restore_attributes if user.invalid?
    user.update exporting_photos: false
  end
end
