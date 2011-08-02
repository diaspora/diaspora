# encoding: utf-8

require 'fileutils'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'

module CarrierWave

  class << self
    attr_accessor :root

    def configure(&block)
      CarrierWave::Uploader::Base.configure(&block)
    end

    def clean_cached_files!
      CarrierWave::Uploader::Base.clean_cached_files!
    end
  end

  class UploadError < StandardError; end
  class IntegrityError < UploadError; end
  class InvalidParameter < UploadError; end
  class ProcessingError < UploadError; end
  class DownloadError < UploadError; end

  autoload :SanitizedFile, 'carrierwave/sanitized_file'
  autoload :Mount, 'carrierwave/mount'
  autoload :RMagick, 'carrierwave/processing/rmagick'
  autoload :ImageScience, 'carrierwave/processing/image_science'
  autoload :MiniMagick, 'carrierwave/processing/mini_magick'
  autoload :VERSION, 'carrierwave/version'

  module Storage
    autoload :Abstract, 'carrierwave/storage/abstract'
    autoload :File, 'carrierwave/storage/file'
    autoload :S3, 'carrierwave/storage/s3'
    autoload :GridFS, 'carrierwave/storage/grid_fs'
    autoload :RightS3, 'carrierwave/storage/right_s3'
    autoload :CloudFiles, 'carrierwave/storage/cloud_files'
  end

  module Uploader
    autoload :Base, 'carrierwave/uploader'
    autoload :Cache, 'carrierwave/uploader/cache'
    autoload :Store, 'carrierwave/uploader/store'
    autoload :Download, 'carrierwave/uploader/download'
    autoload :Callbacks, 'carrierwave/uploader/callbacks'
    autoload :Processing, 'carrierwave/uploader/processing'
    autoload :Versions, 'carrierwave/uploader/versions'
    autoload :Remove, 'carrierwave/uploader/remove'
    autoload :ExtensionWhitelist, 'carrierwave/uploader/extension_whitelist'
    autoload :DefaultUrl, 'carrierwave/uploader/default_url'
    autoload :Proxy, 'carrierwave/uploader/proxy'
    autoload :Url, 'carrierwave/uploader/url'
    autoload :Mountable, 'carrierwave/uploader/mountable'
    autoload :Configuration, 'carrierwave/uploader/configuration'
  end

  module Compatibility
    autoload :Paperclip, 'carrierwave/compatibility/paperclip'
  end

  module Test
    autoload :Matchers, 'carrierwave/test/matchers'
  end

end

if defined?(Merb)

  CarrierWave.root = Merb.dir_for(:public)
  Merb::BootLoader.before_app_loads do
    # Setup path for uploaders and load all of them before classes are loaded
    Merb.push_path(:uploaders, Merb.root / 'app' / 'uploaders', '*.rb')
    Dir.glob(File.join(Merb.load_paths[:uploaders])).each {|f| require f }
  end

elsif defined?(Rails)

  module CarrierWave
    class Railtie < Rails::Railtie
      initializer "carrierwave.setup_paths" do
        CarrierWave.root = Rails.root.join(Rails.public_path).to_s
      end
    end
  end

elsif defined?(Sinatra)

  CarrierWave.root = Sinatra::Application.public

end


require 'carrierwave/orm/activerecord' if defined?(ActiveRecord)
require 'carrierwave/orm/datamapper' if defined?(DataMapper)
require 'carrierwave/orm/sequel' if defined?(Sequel)
require 'carrierwave/orm/mongoid' if defined?(Mongoid)
