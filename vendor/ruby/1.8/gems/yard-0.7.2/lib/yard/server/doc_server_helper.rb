module YARD
  module Server
    # A module that is mixed into {Templates::Template} in order to customize
    # certain template methods.
    module DocServerHelper
      # Modifies {Templates::Helpers::HtmlHelper#url_for} to return a URL instead
      # of a disk location.
      # @param (see Templates::Helpers::HtmlHelper#url_for)
      # @return (see Templates::Helpers::HtmlHelper#url_for)
      def url_for(obj, anchor = nil, relative = false)
        return '' if obj.nil?
        return "/#{obj}" if String === obj
        super(obj, anchor, false)
      end

      # Modifies {Templates::Helpers::HtmlHelper#url_for_file} to return a URL instead
      # of a disk location.
      # @param (see Templates::Helpers::HtmlHelper#url_for_file)
      # @return (see Templates::Helpers::HtmlHelper#url_for_file)
      def url_for_file(filename, anchor = nil)
        if filename.is_a?(CodeObjects::ExtraFileObject)
          filename = filename.filename
        end
        "/#{base_path(router.docs_prefix)}/file/" + filename.sub(%r{^#{@library.source_path.to_s}/}, '') +
          (anchor ? "##{anchor}" : "")
      end

      # @example The base path for a library 'foo'
      #   base_path('docs') # => 'docs/foo'
      # @param [String] path the path prefix for a base path URI
      # @return [String] the base URI for a library with an extra +path+ prefix
      def base_path(path)
        path + (@single_library ? '' : "/#{@library}")
      end

      # @return [Router] convenience method for accessing the router
      def router; @adapter.router end
    end
  end
end
