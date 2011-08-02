require 'fog/core/model'
require 'fog/google/models/storage/files'

module Fog
  module Google
    class Storage

      class Directory < Fog::Model
        extend Fog::Deprecation
        deprecate(:name, :key)
        deprecate(:name=, :key=)

        identity  :key,           :aliases => ['Name', 'name']

        attribute :creation_date, :aliases => 'CreationDate'

        def acl=(new_acl)
          valid_acls = ['private', 'public-read', 'public-read-write', 'authenticated-read']
          unless valid_acls.include?(new_acl)
            raise ArgumentError.new("acl must be one of [#{valid_acls.join(', ')}]")
          end
          @acl = new_acl
        end

        def destroy
          requires :key
          connection.delete_bucket(key)
          true
        rescue Excon::Errors::NotFound
          false
        end

        def files
          @files ||= begin
            Fog::Google::Storage::Files.new(
              :directory    => self,
              :connection   => connection
            )
          end
        end

        def public=(new_public)
          if new_public
            @acl = 'public-read'
          else
            @acl = 'private'
          end
          new_public
        end

        def public_url
          requires :key
          if connection.get_bucket_acl(key).body['AccessControlList'].detect {|entry| entry['Scope']['type'] == 'AllUsers' && entry['Permission'] == 'READ'}
            if key.to_s =~ /^(?:[a-z]|\d(?!\d{0,2}(?:\.\d{1,3}){3}$))(?:[a-z0-9]|\.(?![\.\-])|\-(?![\.])){1,61}[a-z0-9]$/
              "https://#{key}.commondatastorage.googleapis.com"
            else
              "https://commondatastorage.googleapis.com/#{key}"
            end
          else
            nil
          end
        end

        def save
          requires :key
          options = {}
          if @acl
            options['x-goog-acl'] = @acl
          end
          if @location
            options['LocationConstraint'] = @location
          end
          connection.put_bucket(key, options)
          true
        end

      end

    end
  end
end
