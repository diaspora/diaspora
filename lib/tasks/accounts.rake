# frozen_string_literal: true

namespace :accounts do
  desc "Perform migration"
  task :migration, %i[archive_path photos_path new_user_name] => :environment do |_t, args|
    puts "Account migration is requested. You can import a profile or a photos archive or booth."
    args = %i[archive_path photos_path new_user_name].map {|name| [name, args[name]] }.to_h
    process_arguments(args)
    start_time = Time.now.getlocal
    if args[:new_user_name].present?
      import_profile = ImportProfileService.new
      import_profile.import_by_files(args[:archive_path], args[:photos_path], args[:new_user_name])
    else
      puts "Must set a user name and a archive file path or photos file path"
    end
    puts "\n Migration finished took #{Time.now.getlocal - start_time} seconds. (Photos might still be processed)"
  end

  def process_arguments(args)
    request_archive_parameter(args)
    request_photos_parameter(args)
    request_username(args)
    puts "Archive path: #{args[:archive_path]}"
    puts "Photos path: #{args[:photos_path]}"
    puts "New username: #{args[:new_user_name]}"
  end
end

def request_archive_parameter(args)
  return unless args[:archive_path].nil?

  print "Enter the archive (.json, .gz, .zip) path: "
  args[:archive_path] = $stdin.gets.strip
end

def request_photos_parameter(args)
  return unless args[:photos_path].nil?

  print "Enter the photos (.zip) path: "
  args[:photos_path] = $stdin.gets.strip
end

def request_username(args)
  return unless args[:new_user_name].nil?

  print "Enter the new user name: "
  args[:new_user_name] = $stdin.gets.strip
end
