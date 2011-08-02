# encoding: utf-8

require 'mongoid'
require 'carrierwave/validations/active_model'

module CarrierWave
  module Mongoid
    include CarrierWave::Mount
    ##
    # See +CarrierWave::Mount#mount_uploader+ for documentation
    #
    def mount_uploader(column, uploader, options={}, &block)
      options[:mount_on] ||= "#{column}_filename"
      field options[:mount_on]

      super

      alias_method :read_uploader, :read_attribute
      alias_method :write_uploader, :write_attribute

      include CarrierWave::Validations::ActiveModel

      validates_integrity_of  column if uploader_option(column.to_sym, :validate_integrity)
      validates_processing_of column if uploader_option(column.to_sym, :validate_processing)

      after_save "store_#{column}!".to_sym
      before_save "write_#{column}_identifier".to_sym
      after_destroy "remove_#{column}!".to_sym
    end
  end # Mongoid
end # CarrierWave

Mongoid::Document::ClassMethods.send(:include, CarrierWave::Mongoid)