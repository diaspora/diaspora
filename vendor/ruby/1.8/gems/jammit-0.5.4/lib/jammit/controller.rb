module Jammit

  # The JammitController is added to your Rails application when the Gem is
  # loaded. It takes responsibility for /assets, and dynamically packages any
  # missing or uncached asset packages.
  class Controller < ActionController::Base

    VALID_FORMATS   = [:css, :js]

    SUFFIX_STRIPPER = /-(datauri|mhtml)\Z/

    NOT_FOUND_PATH  = "#{PUBLIC_ROOT}/404.html"

    # The "package" action receives all requests for asset packages that haven't
    # yet been cached. The package will be built, cached, and gzipped.
    def package
      parse_request
      case @extension
      when :js
        render :js => (@contents = Jammit.packager.pack_javascripts(@package))
      when Jammit.template_extension.to_sym
        render :js => (@contents = Jammit.packager.pack_templates(@package))
      when :css
        render :text => generate_stylesheets, :content_type => 'text/css'
      end
      cache_package if perform_caching
    rescue Jammit::PackageNotFound
      package_not_found
    end


    private

    # Tells the Jammit::Packager to cache and gzip an asset package. We can't
    # just use the built-in "cache_page" because we need to ensure that
    # the timestamp that ends up in the MHTML is also on the cached file.
    def cache_package
      dir = File.join(page_cache_directory, Jammit.package_path)
      Jammit.packager.cache(@package, @extension, @contents, dir, @variant, @mtime)
    end

    # Generate the complete, timestamped, MHTML url -- if we're rendering a
    # dynamic MHTML package, we'll need to put one URL in the response, and a
    # different one into the cached package.
    def prefix_url(path)
      host = request.port == 80 ? request.host : request.host_with_port
      "#{request.protocol}#{host}#{path}"
    end

    # If we're generating MHTML/CSS, return a stylesheet with the absolute
    # request URL to the client, and cache a version with the timestamped cache
    # URL swapped in.
    def generate_stylesheets
      return @contents = Jammit.packager.pack_stylesheets(@package, @variant) unless @variant == :mhtml
      @mtime      = Time.now
      request_url = prefix_url(request.fullpath)
      cached_url  = prefix_url(Jammit.asset_url(@package, @extension, @variant, @mtime))
      css         = Jammit.packager.pack_stylesheets(@package, @variant, request_url)
      @contents   = css.gsub(request_url, cached_url) if perform_caching
      css
    end

    # Extracts the package name, extension (:css, :js), and variant (:datauri,
    # :mhtml) from the incoming URL.
    def parse_request
      pack       = params[:package]
      @extension = params[:extension].to_sym
      raise PackageNotFound unless (VALID_FORMATS + [Jammit.template_extension.to_sym]).include?(@extension)
      if Jammit.embed_assets
        suffix_match = pack.match(SUFFIX_STRIPPER)
        @variant = Jammit.embed_assets && suffix_match && suffix_match[1].to_sym
        pack.sub!(SUFFIX_STRIPPER, '')
      end
      @package = pack.to_sym
    end

    # Render the 404 page, if one exists, for any packages that don't.
    def package_not_found
      return render(:file => NOT_FOUND_PATH, :status => 404) if File.exists?(NOT_FOUND_PATH)
      render :text => "<h1>404: \"#{@package}\" asset package not found.</h1>", :status => 404
    end

  end

end

# Make the Jammit::Controller available to Rails as a top-level controller.
::JammitController = Jammit::Controller

if defined?(Rails) && (Rails.env.development? || Rails.env.test?)
  ActionController::Base.class_eval do
    append_before_filter { Jammit.reload! }
  end
end
