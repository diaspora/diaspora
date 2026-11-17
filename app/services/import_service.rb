# frozen_string_literal: true

class ImportService
  include Diaspora::Logging

  def import_by_user(user, opts={})
    import_by_files(user.export.current_path, user.exported_photos_file.current_path, user.username, opts)
  end

  def import_by_files(path_to_profile, path_to_photos, username, opts={})
    if path_to_profile.present?
      logger.info "Import for profile #{username} at path #{path_to_profile} requested"
      import_user_profile(path_to_profile, username, opts.merge(photo_migration: path_to_photos.present?))
    end

    user = User.find_by(username: username)
    raise ArgumentError, "Username #{username} should exist before uploading photos." if user.nil?

    if path_to_photos.present?
      logger.info("Importing photos from import file for '#{username}' from #{path_to_photos}")
      import_user_photos(user, path_to_photos)
    end
    remove_file_references(user)
  end

  private

  def import_user_profile(path_to_profile, username, opts)
    raise ArgumentError, "Profile file not found at path: #{path_to_profile}" unless File.exist?(path_to_profile)

    service = MigrationService.new(path_to_profile, username, opts)
    logger.info "Start validating user profile #{username}"
    service.validate
    logger.info "Start importing user profile for '#{username}'"
    service.perform!
    logger.info "Successfully imported profile: #{username}"
  rescue MigrationService::ArchiveValidationFailed => e
    logger.error "Errors in the archive found: #{e.message}"
  rescue MigrationService::MigrationAlreadyExists
    logger.error "Migration record already exists for the user, can't continue"
  rescue MigrationService::SelfMigrationNotAllowed
    logger.error "You can't migrate onto your own account"
  end

  def import_user_photos(user, path_to_photos)
    raise ArgumentError, "Photos file not found at path: #{path_to_photos}" unless File.exist?(path_to_photos)

    uncompressed_photos_folder = unzip_photos_file(path_to_photos)
    user.posts.find_in_batches do |posts|
      import_photos_for_posts(user, posts, uncompressed_photos_folder)
    end
    FileUtils.rm_r(uncompressed_photos_folder)
  end

  def import_photos_for_posts(user, posts, source_dir)
    posts.each do |post|
      post.photos.each do |photo|
        next unless photo.author_id == user.person.id # reshares return the photos of the root post
        next if photo.unprocessed_image_identifier.present? # already stored on this pod

        uploaded_file = photo_file_in_archive(source_dir, photo.remote_photo_name)
        next unless uploaded_file

        # Don't overwrite existing photos if they have the same filename.
        # Generate a new random filename if a conflict exists and re-federate the photo to update on remote pods.
        random_string = File.basename(uploaded_file, ".*")
        conflicting_photo_exists = conflicting_photo_exists?(photo, random_string, File.extname(uploaded_file))
        random_string = SecureRandom.hex(10) if conflicting_photo_exists

        store_and_process_photo(photo, uploaded_file, random_string)

        Diaspora::Federation::Dispatcher.build(user, photo).dispatch if conflicting_photo_exists
      end
    end
  end

  # remote_photo_name comes from the user's archive, so it must not point outside of source_dir
  def photo_file_in_archive(source_dir, photo_name)
    return if photo_name.blank? || File.basename(photo_name) != photo_name

    path = File.join(source_dir, photo_name)
    path if File.file?(path)
  end

  # Also checks the storage, because the scaled versions of other photos and photos from before 2011
  # have file names that don't match the random_string of any photo.
  def conflicting_photo_exists?(photo, random_string, extension)
    return true if Photo.where.not(id: photo.id).exists?(random_string: random_string)

    uploader = UnprocessedImage.new(photo, :unprocessed_image)
    uploader.retrieve_from_store!(random_string + extension)
    [uploader, *uploader.versions.values].any? {|version| version.file.exists? }
  end

  def store_and_process_photo(photo, uploaded_file, random_string)
    File.open(uploaded_file) do |file|
      photo.random_string = random_string
      photo.keep_original_format = true
      photo.unprocessed_image.store! file
      photo.update_remote_path
      photo.save(touch: false)
    end
    photo.queue_processing_job
  end

  def unzip_photos_file(photo_file_path)
    folder = create_folder(photo_file_path)
    destination = File.realpath(folder)
    Zip::File.open(photo_file_path) do |zip_file|
      zip_file.each do |file|
        target_name = File.expand_path(file.name, destination)
        unless target_name == destination || target_name.start_with?(destination + File::SEPARATOR)
          logger.error "Skipping unsafe path in photos archive: #{file.name}"
          next
        end

        zip_file.extract(file, target_name) unless File.exist?(target_name)
      rescue Errno::ENOENT => e
        logger.error e.to_s
      end
    end
    folder
  end

  def create_folder(compressed_file_name)
    extension = File.extname(compressed_file_name)
    folder = compressed_file_name.delete_suffix(extension)
    FileUtils.mkdir(folder) unless File.exist?(folder)
    folder
  end

  def remove_file_references(user)
    user.remove_exported_photos_file
    user.remove_export
    user.save
  end
end
