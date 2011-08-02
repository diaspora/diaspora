task :default => :test

task :rails_env do
  # TODO Do we really need this?
  unless defined? RAILS_ENV
    RAILS_ENV = ENV['RAILS_ENV'] ||= 'development'
  end
end

desc 'Generate a cryptographically secure secret key (this is typically used to generate a secret for cookie sessions).'
task :secret do
  require 'active_support/secure_random'
  puts ActiveSupport::SecureRandom.hex(64)
end

desc 'List versions of all Rails frameworks and the environment'
task :about do
  puts Rails::Info
end

namespace :time do
  namespace :zones do
    desc 'Displays all time zones, also available: time:zones:us, time:zones:local -- filter with OFFSET parameter, e.g., OFFSET=-6'
    task :all do
      build_time_zone_list(:all)
    end

    # desc 'Displays names of US time zones recognized by the Rails TimeZone class, grouped by offset. Results can be filtered with optional OFFSET parameter, e.g., OFFSET=-6'
    task :us do
      build_time_zone_list(:us_zones)
    end

    # desc 'Displays names of time zones recognized by the Rails TimeZone class with the same offset as the system local time'
    task :local do
      require 'active_support'
      require 'active_support/time'
      jan_offset = Time.now.beginning_of_year.utc_offset
      jul_offset = Time.now.beginning_of_year.change(:month => 7).utc_offset
      offset = jan_offset < jul_offset ? jan_offset : jul_offset
      build_time_zone_list(:all, offset)
    end

    # to find UTC -06:00 zones, OFFSET can be set to either -6, -6:00 or 21600
    def build_time_zone_list(method, offset = ENV['OFFSET'])
      require 'active_support'
      require 'active_support/time'
      if offset
        offset = if offset.to_s.match(/(\+|-)?(\d+):(\d+)/)
          sign = $1 == '-' ? -1 : 1
          hours, minutes = $2.to_f, $3.to_f
          ((hours * 3600) + (minutes.to_f * 60)) * sign
        elsif offset.to_f.abs <= 13
          offset.to_f * 3600
        else
          offset.to_f
        end
      end
      previous_offset = nil
      ActiveSupport::TimeZone.__send__(method).each do |zone|
        if offset.nil? || offset == zone.utc_offset
          puts "\n* UTC #{zone.formatted_offset} *" unless zone.utc_offset == previous_offset
          puts zone.name
          previous_offset = zone.utc_offset
        end
      end
      puts "\n"
    end
  end
end
