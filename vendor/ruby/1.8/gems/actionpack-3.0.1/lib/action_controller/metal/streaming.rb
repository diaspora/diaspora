require 'active_support/core_ext/file/path'

module ActionController #:nodoc:
  # Methods for sending arbitrary data and for streaming files to the browser,
  # instead of rendering.
  module Streaming
    extend ActiveSupport::Concern

    include ActionController::Rendering

    DEFAULT_SEND_FILE_OPTIONS = {
      :type         => 'application/octet-stream'.freeze,
      :disposition  => 'attachment'.freeze,
    }.freeze

    protected
      # Sends the file. This uses a server-appropriate method (such as X-Sendfile)
      # via the Rack::Sendfile middleware. The header to use is set via
      # config.action_dispatch.x_sendfile_header, and defaults to "X-Sendfile".
      # Your server can also configure this for you by setting the X-Sendfile-Type header.
      #
      # Be careful to sanitize the path parameter if it is coming from a web
      # page. <tt>send_file(params[:path])</tt> allows a malicious user to
      # download any file on your server.
      #
      # Options:
      # * <tt>:filename</tt> - suggests a filename for the browser to use.
      #   Defaults to <tt>File.basename(path)</tt>.
      # * <tt>:type</tt> - specifies an HTTP content type. Defaults to 'application/octet-stream'. You can specify
      #   either a string or a symbol for a registered type register with <tt>Mime::Type.register</tt>, for example :json
      # * <tt>:disposition</tt> - specifies whether the file will be shown inline or downloaded.
      #   Valid values are 'inline' and 'attachment' (default).
      # * <tt>:status</tt> - specifies the status code to send with the response. Defaults to '200 OK'.
      # * <tt>:url_based_filename</tt> - set to +true+ if you want the browser guess the filename from
      #   the URL, which is necessary for i18n filenames on certain browsers
      #   (setting <tt>:filename</tt> overrides this option).
      #
      # The default Content-Type and Content-Disposition headers are
      # set to download arbitrary binary files in as many browsers as
      # possible.  IE versions 4, 5, 5.5, and 6 are all known to have
      # a variety of quirks (especially when downloading over SSL).
      #
      # Simple download:
      #
      #   send_file '/path/to.zip'
      #
      # Show a JPEG in the browser:
      #
      #   send_file '/path/to.jpeg', :type => 'image/jpeg', :disposition => 'inline'
      #
      # Show a 404 page in the browser:
      #
      #   send_file '/path/to/404.html', :type => 'text/html; charset=utf-8', :status => 404
      #
      # Read about the other Content-* HTTP headers if you'd like to
      # provide the user with more information (such as Content-Description) in
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.11.
      #
      # Also be aware that the document may be cached by proxies and browsers.
      # The Pragma and Cache-Control headers declare how the file may be cached
      # by intermediaries.  They default to require clients to validate with
      # the server before releasing cached responses.  See
      # http://www.mnot.net/cache_docs/ for an overview of web caching and
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9
      # for the Cache-Control header spec.
      def send_file(path, options = {}) #:doc:
        raise MissingFile, "Cannot read file #{path}" unless File.file?(path) and File.readable?(path)

        options[:filename] ||= File.basename(path) unless options[:url_based_filename]
        send_file_headers! options

        if options[:x_sendfile]
          ActiveSupport::Deprecation.warn(":x_sendfile is no longer needed in send_file", caller)
        end

        self.status = options[:status] || 200
        self.content_type = options[:content_type] if options.key?(:content_type)
        self.response_body = File.open(path, "rb")
      end

      # Sends the given binary data to the browser. This method is similar to
      # <tt>render :text => data</tt>, but also allows you to specify whether
      # the browser should display the response as a file attachment (i.e. in a
      # download dialog) or as inline data. You may also set the content type,
      # the apparent file name, and other things.
      #
      # Options:
      # * <tt>:filename</tt> - suggests a filename for the browser to use.
      # * <tt>:type</tt> - specifies an HTTP content type. Defaults to 'application/octet-stream'. You can specify
      #   either a string or a symbol for a registered type register with <tt>Mime::Type.register</tt>, for example :json
      # * <tt>:disposition</tt> - specifies whether the file will be shown inline or downloaded.
      #   Valid values are 'inline' and 'attachment' (default).
      # * <tt>:status</tt> - specifies the status code to send with the response. Defaults to '200 OK'.
      #
      # Generic data download:
      #
      #   send_data buffer
      #
      # Download a dynamically-generated tarball:
      #
      #   send_data generate_tgz('dir'), :filename => 'dir.tgz'
      #
      # Display an image Active Record in the browser:
      #
      #   send_data image.data, :type => image.content_type, :disposition => 'inline'
      #
      # See +send_file+ for more information on HTTP Content-* headers and caching.
      #
      # <b>Tip:</b> if you want to stream large amounts of on-the-fly generated
      # data to the browser, then use <tt>render :text => proc { ... }</tt>
      # instead. See ActionController::Base#render for more information.
      def send_data(data, options = {}) #:doc:
        send_file_headers! options.dup
        render options.slice(:status, :content_type).merge(:text => data)
      end

    private
      def send_file_headers!(options)
        options.update(DEFAULT_SEND_FILE_OPTIONS.merge(options))
        [:type, :disposition].each do |arg|
          raise ArgumentError, ":#{arg} option required" if options[arg].nil?
        end

        if options.key?(:length)
          ActiveSupport::Deprecation.warn("You do not need to provide the file's length", caller)
        end

        disposition = options[:disposition]
        disposition += %(; filename="#{options[:filename]}") if options[:filename]

        content_type = options[:type]

        if content_type.is_a?(Symbol)
          extension = Mime[content_type]
          raise ArgumentError, "Unknown MIME type #{options[:type]}" unless extension
          self.content_type = extension
        else
          self.content_type = content_type
        end

        headers.merge!(
          'Content-Disposition'       => disposition,
          'Content-Transfer-Encoding' => 'binary'
        )

        response.sending_file = true

        # Fix a problem with IE 6.0 on opening downloaded files:
        # If Cache-Control: no-cache is set (which Rails does by default),
        # IE removes the file it just downloaded from its cache immediately
        # after it displays the "open/save" dialog, which means that if you
        # hit "open" the file isn't there anymore when the application that
        # is called for handling the download is run, so let's workaround that
        response.cache_control[:public] ||= false
      end
  end
end
