# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class Base
    attr_accessor :start_time, :directory, :full_path

    def initialize(start_time = Time.now)
      @start_time = start_time
      @directory = "tmp/export-for-mysql"
      @full_path = "#{Rails.root}/#{directory}"
    end

    def log(message)
      if ['development', 'production'].include?(Rails.env)
        puts "#{sprintf("%.2f", Time.now - start_time)}s #{message}"
      end
      Rails.logger.debug(message) if Rails.logger
    end
  end
end