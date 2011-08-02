require 'fog/core/model'

module Fog
  module AWS
    class Compute

      class KeyPair < Fog::Model
        extend Fog::Deprecation
        deprecate(:material, :private_key)

        identity  :name,        :aliases => 'keyName'

        attribute :fingerprint, :aliases => 'keyFingerprint'
        attribute :private_key, :aliases => 'keyMaterial'

        attr_accessor :public_key

        def destroy
          requires :name

          connection.delete_key_pair(name)
          true
        end

        def save
          requires :name

          data = if public_key
            connection.import_key_pair(name, public_key).body
          else
            connection.create_key_pair(name).body
          end
          new_attributes = data.reject {|key,value| !['keyFingerprint', 'keyMaterial', 'keyName'].include?(key)}
          merge_attributes(new_attributes)
          true
        end

        private

      end

    end
  end
end
