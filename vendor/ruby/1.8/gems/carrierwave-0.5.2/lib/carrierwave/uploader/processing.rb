# encoding: utf-8

module CarrierWave
  module Uploader
    module Processing
      extend ActiveSupport::Concern

      include CarrierWave::Uploader::Callbacks

      included do
        after :cache, :process!
      end

      module ClassMethods

        ##
        # Lists processor callbacks declared
        #
        # === Returns
        #
        # [Array[Array[Symbol, Array]]] a list of processor callbacks which have been declared for this uploader
        #
        def processors
          @processors ||= []
        end

        ##
        # Adds a processor callback which applies operations as a file is uploaded.
        # The argument may be the name of any method of the uploader, expressed as a symbol,
        # or a list of such methods, or a hash where the key is a method and the value is
        # an array of arguments to call the method with
        #
        # === Parameters
        #
        # args (*Symbol, Hash{Symbol => Array[]})
        #
        # === Examples
        #
        #     class MyUploader < CarrierWave::Uploader::Base
        #
        #       process :sepiatone, :vignette
        #       process :scale => [200, 200]
        #
        #       def sepiatone
        #         ...
        #       end
        #
        #       def vignette
        #         ...
        #       end
        #
        #       def scale(height, width)
        #         ...
        #       end
        #     end
        #
        def process(*args)
          args.each do |arg|
            if arg.is_a?(Hash)
              arg.each do |method, args|
                processors.push([method, args])
              end
            else
              processors.push([arg, []])
            end
          end
        end

      end # ClassMethods

      ##
      # Apply all process callbacks added through CarrierWave.process
      #
      def process!(new_file=nil)
        if enable_processing
          self.class.processors.each do |method, args|
            self.send(method, *args)
          end
        end
      end

    end # Processing
  end # Uploader
end # CarrierWave
