# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class Base
    attr_accessor :start_time

    def initialize(start_time = Time.now)
      @start_time = start_time
    end

    def log(message)
      if ['development', 'production'].include?(Rails.env)
        puts "#{sprintf("%.2f", Time.now - start_time)}s #{message}"
      end
      Rails.logger.debug(message) if Rails.logger
    end

    def export_directory
      "tmp/export-for-mysql"
    end

    def export_path
      "#{Rails.root}/#{export_directory}"
    end
  end
end