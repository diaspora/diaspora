module Fog
  module Local
    class Storage < Fog::Service

      requires :local_root

      model_path 'fog/local/models/storage'
      collection  :directories
      model       :directory
      model       :file
      collection  :files

      class Mock

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset_data(keys=data.keys)
          for key in [*keys]
            data.delete(key)
          end
        end

        def initialize(options={})
          @local_root = ::File.expand_path(options[:local_root])
          @data       = self.class.data[@local_root]
        end

        def local_root
          @local_root
        end

        def path(partial)
          partial
        end
      end

      class Real

        def initialize(options={})
          @local_root = ::File.expand_path(options[:local_root])
        end

        def local_root
          @local_root
        end

        def path_to(partial)
          ::File.join(@local_root, partial)
        end
      end

    end
  end
end
