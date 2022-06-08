# frozen_string_literal: true

class MigrationService
  attr_reader :archive_path, :new_user_name, :opts

  delegate :errors, :warnings, to: :archive_validator

  def initialize(archive_path, new_user_name, opts={})
    @archive_path = archive_path
    @new_user_name = new_user_name
    @opts = opts
  end

  def validate
    return unless archive_file_exists?

    archive_validator.validate
    raise ArchiveValidationFailed, errors.join("\n") if errors.any?
    raise MigrationAlreadyExists if AccountMigration.where(old_person: old_person).any?
    raise SelfMigrationNotAllowed if self_import?
  end

  def perform!
    find_or_create_user
    import_archive
    run_migration
  ensure
    remove_intermediate_file
  end

  def self_import?
    source_diaspora_id = archive_validator.archive_author_diaspora_id
    target_diaspora_id = "#{new_user_name}#{User.diaspora_id_host}"
    source_diaspora_id == target_diaspora_id
  end

  # when old person can't be resolved we still import data but we don't create&perform AccountMigration instance
  def only_import?
    old_person.nil?
  end

  private

  def find_or_create_user
    archive_importer.find_or_create_user(username: new_user_name, password: SecureRandom.hex)
  end

  def import_archive
    archive_importer.import(opts)
  end

  def run_migration
    account_migration.save
    account_migration.perform!
  end

  def account_migration
    @account_migration ||= AccountMigration.new(
      old_person:             old_person,
      new_person:             archive_importer.user.person,
      old_private_key:        archive_importer.serialized_private_key,
      old_person_diaspora_id: archive_importer.archive_author_diaspora_id,
      archive_contacts:       archive_importer.contacts,
      remote_photo_path:      remote_photo_path
    )
  end

  def old_person
    @old_person ||= Person.by_account_identifier(archive_validator.archive_author_diaspora_id)
  end

  def archive_importer
    @archive_importer ||= ArchiveImporter.new(archive_validator.archive_hash)
  end

  def archive_validator
    @archive_validator ||= ArchiveValidator.new(archive_file)
  end

  def archive_file
    return uncompressed_zip if zip_file?
    return uncompressed_gz if gzip_file?

    File.new(archive_path, "r")
  end

  def archive_file_exists?
    File.exist?(archive_path)
  end

  def zip_file?
    filetype = MIME::Types.type_for(archive_path).first.content_type
    filetype.eql?("application/zip")
  end

  def gzip_file?
    filetype = MIME::Types.type_for(archive_path).first.content_type
    filetype.eql?("application/gzip")
  end

  def uncompressed_gz
    target_dir = File.dirname(archive_path) + Pathname::SEPARATOR_LIST
    unzipped_archive_file = "#{File.join(target_dir, SecureRandom.hex)}.json" # never override an existing file

    Zlib::GzipReader.open(archive_path) {|gz|
      File.open(unzipped_archive_file, "w") do |output_stream|
        IO.copy_stream(gz, output_stream)
      end
      @intermediate_file = unzipped_archive_file
    }
    File.new(unzipped_archive_file, "r")
  end

  def uncompressed_zip
    target_dir = File.dirname(archive_path) + Pathname::SEPARATOR_LIST
    zip_stream = Zip::InputStream.open(archive_path)
    while entry = zip_stream.get_next_entry # rubocop:disable Lint/AssignmentInCondition
      next unless entry.name.end_with?(".json")

      target_file = "#{File.join(target_dir, SecureRandom.hex)}.json" # never override an existing file
      entry.extract(target_file)
      @intermediate_file = target_file
      return File.new(target_file, "r")
    end
  end

  def remove_intermediate_file
    # If an unzip operation created an unzipped file, remove it after migration
    return if @intermediate_file.nil?
    return unless File.exist?(@intermediate_file)

    File.delete(@intermediate_file)
  end

  def remote_photo_path
    return unless opts.fetch(:photo_migration, false)

    if AppConfig.environment.s3.enable?
      return "https://#{AppConfig.environment.s3.bucket.get}.s3.amazonaws.com/uploads/images/"
    end

    "#{AppConfig.pod_uri}uploads/images/"
  end

  class ArchiveValidationFailed < RuntimeError
  end

  class MigrationAlreadyExists < RuntimeError
  end

  class SelfMigrationNotAllowed < RuntimeError
  end
end
