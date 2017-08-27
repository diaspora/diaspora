# frozen_string_literal: true

if AppConfig.environment.assets.upload? && AppConfig.environment.s3.enable?
  # Monkey patch to make Rails.root available early
  require 'pathname'
  module Rails
    def self.root
      @@root ||= Pathname.new(__FILE__).dirname.join('..')
    end
  end

  require 'asset_sync'
end
