require 'fog/core/model'

module Fog
  module Local
    class Storage

      class File < Fog::Model

        identity  :key,             :aliases => 'Key'

        attribute :content_length,  :aliases => 'Content-Length'
        # attribute :content_type,    :aliases => 'Content-Type'
        attribute :last_modified,   :aliases => 'Last-Modified'

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
          ::File.delete(path)
          true
        end

        def public=(new_public)
          new_public
        end

        def public_url
          nil
        end

        def save(options = {})
          requires :body, :directory, :key
          file = ::File.new(path, 'w')
          if body.is_a?(String)
            file.write(body)
          else
            file.write(body.read)
          end
          file.close
          merge_attributes(
            :content_length => ::File.size(path),
            :last_modified  => ::File.mtime(path)
          )
          true
        end

        private

        def directory=(new_directory)
          @directory = new_directory
        end

        def path
          connection.path_to(::File.join(directory.key, CGI.escape(key)))
        end

      end

    end
  end
end
