# encoding: utf-8

require 'dm-core'

module CarrierWave
  module DataMapper

    include CarrierWave::Mount

    ##
    # See +CarrierWave::Mount#mount_uploader+ for documentation
    #
    def mount_uploader(column, uploader, options={}, &block)
      super

      alias_method :read_uploader, :attribute_get
      alias_method :write_uploader, :attribute_set
      after :save, "store_#{column}!".to_sym
      pre_hook = ::DataMapper.const_defined?(:Validate) ? :valid? : :save
      before pre_hook, "write_#{column}_identifier".to_sym
      after :destroy, "remove_#{column}!".to_sym

      # FIXME: Hack to work around Datamapper not triggering callbacks
      # for objects that are not dirty. By explicitly calling
      # attribute_set we are marking the record as dirty.
      class_eval <<-RUBY
        def remove_#{column}=(value)
          _mounter(:#{column}).remove = value
          attribute_set(:#{column}, '') if _mounter(:#{column}).remove?
        end
      RUBY
    end

  end # DataMapper
end # CarrierWave

DataMapper::Model.send(:include, CarrierWave::DataMapper)
