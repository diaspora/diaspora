# frozen_string_literal: true

namespace :accounts do
  desc "Perform migration"
  task :migration, %i[archive_path new_user_name] => :environment do |_t, args|
    puts "Account migration is requested"
    args = %i[archive_path new_user_name].map {|name| [name, args[name]] }.to_h
    process_arguments(args)

    begin
      service = MigrationService.new(args[:archive_path], args[:new_user_name])
      service.validate
      puts "Warnings:\n#{service.warnings.join("\n")}\n-----" if service.warnings.any?
      if service.only_import?
        puts "Warning: Archive owner is not fetchable. Proceeding with data import, but account migration record "\
          "won't  be created"
      end
      print "Do you really want to execute the archive import? Note: this is irreversible! [y/N]: "
      next unless $stdin.gets.strip.casecmp?("y")

      start_time = Time.now.getlocal
      service.perform!
      puts service.only_import? ? "Data import complete!" : "Data import and migration complete!"
      puts "Migration took #{Time.now.getlocal - start_time} seconds"
    rescue MigrationService::ArchiveValidationFailed => exception
      puts "Errors in the archive found:\n#{exception.message}\n-----"
    rescue MigrationService::MigrationAlreadyExists
      puts "Migration record already exists for the user, can't continue"
    end
  end

  def process_arguments(args)
    if args[:archive_path].nil?
      print "Enter the archive path: "
      args[:archive_path] = $stdin.gets.strip
    end
    if args[:new_user_name].nil?
      print "Enter the new user name: "
      args[:new_user_name] = $stdin.gets.strip
    end
    puts "Archive path: #{args[:archive_path]}"
    puts "New username: #{args[:new_user_name]}"
  end
end
