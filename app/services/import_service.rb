# frozen_string_literal: true

class ImportService
  include Diaspora::Logging

  def import_by_user(user, import_parameters)
    profile_path = import_parameters["profile_path"]
    photos_path = import_parameters["photos_path"]

    import_by_files(user, profile_path, photos_path)
  end

  def import_by_files(user, path_to_profile, path_to_photos, opts={})
    import_profile_if_present(opts, path_to_photos, path_to_profile, user.username)

    import_photos_if_present(path_to_photos, user)
    remove_import_files(path_to_profile, path_to_photos)
  end

  private

  def import_photos_if_present(path_to_photos, user)
    if path_to_photos.present?
      logger.info("Importing photos from import file for '#{user.username}' from #{path_to_photos}")
      import_user_photos(user, path_to_photos)
    end
  end

  def import_profile_if_present(opts, path_to_photos, path_to_profile, username)
    return if path_to_profile.blank?

    logger.info "Import for profile #{username} at path #{path_to_profile} requested"
    import_user_profile(path_to_profile, username, opts.merge(photo_migration: path_to_photos.present?))
  end

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
        uploaded_file = "#{source_dir}/#{photo.remote_photo_name}"
        next unless File.exist?(uploaded_file) && photo.remote_photo_name.present?

        # Don't overwrite existing photos if they have the same filename.
        # Generate a new random filename if a conflict exists and re-federate the photo to update on remote pods.
        random_string = File.basename(uploaded_file, ".*")
        conflicting_photo_exists = Photo.where.not(id: photo.id).exists?(random_string: random_string)
        random_string = SecureRandom.hex(10) if conflicting_photo_exists

        store_and_process_photo(photo, uploaded_file, random_string)

        Diaspora::Federation::Dispatcher.build(user, photo).dispatch if conflicting_photo_exists
      end
    end
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
    Zip::File.open(photo_file_path) do |zip_file|
      zip_file.each do |file|
        target_name = "#{folder}#{Pathname::SEPARATOR_LIST}#{file}"
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

  # Removes import files after processing
  # @param [*String] files
  def remove_import_files(*files)
    files.each do |file|
      File.delete(file) if file && File.exist?(file)
    end
  end
end
