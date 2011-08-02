require 'fog/core/model'

module Fog
  module Rackspace
    class Storage

      class File < Fog::Model

        identity  :key,             :aliases => 'name'

        attribute :content_length,  :aliases => ['bytes', 'Content-Length'], :type => :integer
        attribute :content_type,    :aliases => ['content_type', 'Content-Type']
        attribute :etag,            :aliases => ['hash', 'Etag']
        attribute :last_modified,   :aliases => ['last_modified', 'Last-Modified'], :type => :time

        def body
          attributes[:body] ||= if last_modified
            collection.get(identity).body
          else
            ''
          end
        end

        def body=(new_body)
          attributes[:body] = new_body
        end

        def directory
          @directory
        end

        def destroy
          requires :directory, :key
          connection.delete_object(directory.key, key)
          true
        end

        def owner=(new_owner)
          if new_owner
            attributes[:owner] = {
              :display_name => new_owner['DisplayName'],
              :id           => new_owner['ID']
            }
          end
        end

        def public=(new_public)
          new_public
        end

        def public_url
          requires :directory, :key
          if @directory.public_url
            "#{@directory.public_url}/#{key}"
          end
        end

        def save(options = {})
          requires :body, :directory, :key
          data = connection.put_object(directory.key, key, body, options)
          merge_attributes(data.headers)
          if body.is_a?(String)
            self.content_length = body.size
          else
            self.content_length = ::File.size(body.path)
          end
          true
        end

        private

        def directory=(new_directory)
          @directory = new_directory
        end

      end

    end
  end
end
