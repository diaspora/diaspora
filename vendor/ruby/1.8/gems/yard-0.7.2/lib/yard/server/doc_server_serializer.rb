require 'webrick/httputils'

module YARD
  module Server
    # A custom {Serializers::Base serializer} which returns resource URLs instead of
    # static relative paths to files on disk.
    class DocServerSerializer < Serializers::FileSystemSerializer
      include WEBrick::HTTPUtils

      def initialize(command)
        super(:command => command, :extension => '')
      end

      def serialized_path(object)
        path = case object
        when CodeObjects::RootObject
          "toplevel"
        when CodeObjects::MethodObject
          return escape_path(serialized_path(object.namespace) + (object.scope == :instance ? ":" : ".") + object.name.to_s)
        when CodeObjects::ConstantObject, CodeObjects::ClassVariableObject
          return escape_path(serialized_path(object.namespace)) + "##{object.name}-#{object.type}"
        else
          object.path.gsub('::', '/')
        end
        command = options[:command]
        library_path = command.single_library ? '' : '/' + command.library.to_s
        return escape_path(File.join('', command.adapter.router.docs_prefix, library_path, path))
      end
    end
  end
end
