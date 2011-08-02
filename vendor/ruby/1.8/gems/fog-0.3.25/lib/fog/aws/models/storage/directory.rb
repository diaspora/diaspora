require 'fog/core/model'
require 'fog/aws/models/storage/files'

module Fog
  module AWS
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

        def location
          requires :key
          data = connection.get_bucket_location(key)
          data.body['LocationConstraint']
        end

        def location=(new_location)
          @location = new_location
        end

        def files
          @files ||= begin
            Fog::AWS::Storage::Files.new(
              :directory    => self,
              :connection   => connection
            )
          end
        end

        def payer
          requires :key
          data = connection.get_request_payment(key)
          data.body['Payer']
        end

        def payer=(new_payer)
          requires :key
          connection.put_request_payment(key, new_payer)
          @payer = new_payer
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
          if connection.get_bucket_acl(key).body['AccessControlList'].detect {|grant| grant['Grantee']['URI'] == 'http://acs.amazonaws.com/groups/global/AllUsers' && grant['Permission'] == 'READ'}
            if key.to_s =~ /^(?:[a-z]|\d(?!\d{0,2}(?:\.\d{1,3}){3}$))(?:[a-z0-9]|\.(?![\.\-])|\-(?![\.])){1,61}[a-z0-9]$/
              "https://#{key}.s3.amazonaws.com"
            else
              "https://s3.amazonaws.com/#{key}"
            end
          else
            nil
          end
        end

        def save
          requires :key
          options = {}
          if @acl
            options['x-amz-acl'] = @acl
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
