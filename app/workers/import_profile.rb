# frozen_string_literal: true

module Workers
  class ImportProfile < Base
    sidekiq_options queue: :medium

    include Diaspora::Logging

    def perform(user_id)
      user = User.find_by(username: user_id)
      if user.nil?
        logger.error "A user with name #{user_id} not a local user"
      else
        logger.info "Import for profile #{user_id} at path #{user.export.current_path} requested"
        import_user_profile(user.export.current_path, user_id)
        if user.exported_photos_file&.current_path&.present?
          logger.info("Importing photos from import file")
          import_user_photos(user)
        end
        remove_file_references(user)
      end
    end

    private

    def import_user_profile(path_to_profile, username)
      return unless File.exist?(path_to_profile)

      service = MigrationService.new(path_to_profile, username)
      logger.info "Start validating user profile #{username}"
      service.validate
      logger.info "Start importing user profile for #{username}"
      service.perform!
      logger.info "Successfully imported profile: #{username}"
    rescue MigrationService::ArchiveValidationFailed => e
      logger.error "Errors in the archive found: #{e.message}"
    rescue MigrationService::MigrationAlreadyExists
      logger.error "Migration record already exists for the user, can't continue"
    rescue MigrationService::SelfMigrationNotAllowed
      logger.error "You can't migrate onto your own account"
    ensure
      service&.remove_intermediate_file
    end

    def import_user_photos(user)
      return if user.exported_photos_file&.current_path&.nil?

      return unless File.exist?(user.exported_photos_file.current_path)

      unzip_photos_file(user.exported_photos_file.current_path)
      source_dir = folder_from_filename(user.exported_photos_file.current_path)
      user.posts.find_in_batches do |posts|
        import_photos_for_posts(posts, source_dir)
      end
    end

    def import_photos_for_posts(posts, source_dir)
      posts.each do |post|
        post.photos.each do |photo|
          uploaded_file = "#{source_dir}/#{photo.remote_photo_name}"
          next unless File.exist?(uploaded_file) && photo.remote_photo_name.present?

          File.open(uploaded_file) do |file|
            photo.random_string = File.basename(uploaded_file, ".*")
            photo.unprocessed_image = file
            photo.save(touch: false)
          end
          photo.queue_processing_job
        end
      end
    end

    def unzip_photos_file(photo_file_path)
      folder = folder_from_filename(photo_file_path)
      FileUtils.mkdir(folder) unless File.exist?(folder)

      Zip::File.open(photo_file_path) do |zip_file|
        zip_file.each do |file|
          target_name = "#{folder}#{Pathname::SEPARATOR_LIST}#{file}"
          zip_file.extract(file, target_name) unless File.exist?(target_name)
        rescue Errno::ENOENT => e
          logger.error e.to_s
        end
      end
    end

    def folder_from_filename(filename)
      extension = File.extname(filename)
      filename.delete_suffix(extension)
    end

    def remove_file_references(user)
      user.remove_exported_photos_file
      user.remove_export
      user.save
    end
  end
end
