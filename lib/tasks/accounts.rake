# frozen_string_literal: true

namespace :accounts do
  desc "Perform migration"
  task :migration,
       %i[archive_path photos_path new_user_name import_settings import_profile] => :environment do |_t, args|
    puts "Account migration is requested. You can import a profile or a photos archive or both."
    args = %i[archive_path photos_path new_user_name import_settings import_profile]
           .map {|name| [name, args[name]] }.to_h
    process_arguments(args)
    start_time = Time.now.getlocal
    if args[:new_user_name].present? && (args[:archive_path].present? || args[:photos_path].present?)
      ImportService.new.import_by_files(args[:archive_path], args[:photos_path], args[:new_user_name],
                                        args.slice(:import_settings, :import_profile))
      puts "\n Migration completed in #{Time.now.getlocal - start_time} seconds. (Photos might still be processed in)"
    else
      puts "Must set a user name and a archive file path or photos file path"
    end
  end

  def process_arguments(args)
    args[:archive_path] = request_parameter(args[:archive_path], "Enter the archive (.json, .gz, .zip) path: ")
    args[:photos_path] = request_parameter(args[:photos_path], "Enter the photos (.zip) path: ")
    args[:new_user_name] = request_parameter(args[:new_user_name], "Enter the new user name: ")
    args[:import_settings] = request_boolean_parameter(args[:import_settings], "Import and overwrite settings [Y/n]: ")
    args[:import_profile] = request_boolean_parameter(args[:import_profile], "Import and overwrite profile [Y/n]: ")

    puts "Archive path: #{args[:archive_path]}"
    puts "Photos path: #{args[:photos_path]}"
    puts "New username: #{args[:new_user_name]}"
    puts "Import settings: #{args[:import_settings]}"
    puts "Import profile: #{args[:import_profile]}"
  end

  def request_parameter(arg, text)
    return arg unless arg.nil?

    print text
    $stdin.gets.strip
  end

  def request_boolean_parameter(arg, text, default: true)
    return arg == "true" unless arg.nil?

    print text
    response = $stdin.gets.strip.downcase

    return default if response == ""

    response[0] == "y"
  end
end
