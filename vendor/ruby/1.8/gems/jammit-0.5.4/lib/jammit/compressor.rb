module Jammit

  # Uses the YUI Compressor or Closure Compiler to compress JavaScript.
  # Always uses YUI to compress CSS (Which means that Java must be installed.)
  # Also knows how to create a concatenated JST file.
  # If "embed_assets" is turned on, creates "mhtml" and "datauri" versions of
  # all stylesheets, with all enabled assets inlined into the css.
  class Compressor

    # Mapping from extension to mime-type of all embeddable assets.
    EMBED_MIME_TYPES = {
      '.png'  => 'image/png',
      '.jpg'  => 'image/jpeg',
      '.jpeg' => 'image/jpeg',
      '.gif'  => 'image/gif',
      '.tif'  => 'image/tiff',
      '.tiff' => 'image/tiff',
      '.ttf'  => 'font/truetype',
      '.otf'  => 'font/opentype',
      '.woff' => 'font/woff'
    }

    # Font extensions for which we allow embedding:
    EMBED_EXTS      = EMBED_MIME_TYPES.keys
    EMBED_FONTS     = ['.ttf', '.otf']

    # (32k - padding) maximum length for data-uri assets (an IE8 limitation).
    MAX_IMAGE_SIZE  = 32700

    # CSS asset-embedding regexes for URL rewriting.
    EMBED_DETECTOR  = /url\(['"]?([^\s)]+\.[a-z]+)(\?\d+)?['"]?\)/
    EMBEDDABLE      = /[\A\/]embed\//
    EMBED_REPLACER  = /url\(__EMBED__(.+?)(\?\d+)?\)/

    # MHTML file constants.
    MHTML_START     = "/*\r\nContent-Type: multipart/related; boundary=\"MHTML_MARK\"\r\n\r\n"
    MHTML_SEPARATOR = "--MHTML_MARK\r\n"
    MHTML_END       = "\r\n--MHTML_MARK--\r\n*/\r\n"

    # JST file constants.
    JST_START       = "(function(){"
    JST_END         = "})();"

    COMPRESSORS = {
      :yui     => YUI::JavaScriptCompressor,
      :closure => Closure::Compiler
    }

    DEFAULT_OPTIONS = {
      :yui     => {:munge => true},
      :closure => {}
    }

    # Creating a compressor initializes the internal YUI Compressor from
    # the "yui-compressor" gem, or the internal Closure Compiler from the
    # "closure-compiler" gem.
    def initialize
      @css_compressor = YUI::CssCompressor.new(Jammit.css_compressor_options || {})
      flavor          = Jammit.javascript_compressor || Jammit::DEFAULT_COMPRESSOR
      @options        = DEFAULT_OPTIONS[flavor].merge(Jammit.compressor_options || {})
      @js_compressor  = COMPRESSORS[flavor].new(@options)
    end

    # Concatenate together a list of JavaScript paths, and pass them through the
    # YUI Compressor (with munging enabled). JST can optionally be included.
    def compress_js(paths)
      if (jst_paths = paths.grep(Jammit.template_extension_matcher)).empty?
        js = concatenate(paths)
      else
        js = concatenate(paths - jst_paths) + compile_jst(jst_paths)
      end
      Jammit.compress_assets ? @js_compressor.compress(js) : js
    end

    # Concatenate and compress a list of CSS stylesheets. When compressing a
    # :datauri or :mhtml variant, post-processes the result to embed
    # referenced assets.
    def compress_css(paths, variant=nil, asset_url=nil)
      @asset_contents = {}
      css = concatenate_and_tag_assets(paths, variant)
      css = @css_compressor.compress(css) if Jammit.compress_assets
      case variant
      when nil      then return css
      when :datauri then return with_data_uris(css)
      when :mhtml   then return with_mhtml(css, asset_url)
      else raise PackageNotFound, "\"#{variant}\" is not a valid stylesheet variant"
      end
    end

    # Compiles a single JST file by writing out a javascript that adds
    # template properties to a top-level template namespace object. Adds a
    # JST-compilation function to the top of the package, unless you've
    # specified your own preferred function, or turned it off.
    # JST templates are named with the basename of their file.
    def compile_jst(paths)
      namespace   = Jammit.template_namespace
      paths       = paths.grep(Jammit.template_extension_matcher).sort
      base_path   = find_base_path(paths)
      compiled    = paths.map do |path|
        contents  = read_binary_file(path)
        contents  = contents.gsub(/\n/, '').gsub("'", '\\\\\'')
        name      = template_name(path, base_path)
        "#{namespace}['#{name}'] = #{Jammit.template_function}('#{contents}');"
      end
      compiler = Jammit.include_jst_script ? read_binary_file(DEFAULT_JST_SCRIPT) : '';
      setup_namespace = "#{namespace} = #{namespace} || {};"
      [JST_START, setup_namespace, compiler, compiled, JST_END].flatten.join("\n")
    end


    private

    # Given a set of paths, find a common prefix path.
    def find_base_path(paths)
      return nil if paths.length <= 1
      paths.sort!
      first = paths.first.split('/')
      last  = paths.last.split('/')
      i = 0
      while first[i] == last[i] && i <= first.length
        i += 1
      end
      res = first.slice(0, i).join('/')
      res.empty? ? nil : res
    end

    # Determine the name of a JS template. If there's a common base path, use
    # the namespaced prefix. Otherwise, simply use the filename.
    def template_name(path, base_path)
      return File.basename(path, ".#{Jammit.template_extension}") unless base_path
      path.gsub(/\A#{base_path}\/(.*)\.#{Jammit.template_extension}\Z/, '\1')
    end

    # In order to support embedded assets from relative paths, we need to
    # expand the paths before contatenating the CSS together and losing the
    # location of the original stylesheet path. Validate the assets while we're
    # at it.
    def concatenate_and_tag_assets(paths, variant=nil)
      stylesheets = [paths].flatten.map do |css_path|
        contents = read_binary_file(css_path)
        contents.gsub(EMBED_DETECTOR) do |url|
          ipath, cpath = Pathname.new($1), Pathname.new(File.expand_path(css_path))
          is_url = URI.parse($1).absolute?
          is_url ? url : "url(#{construct_asset_path(ipath, cpath, variant)})"
        end
      end
      stylesheets.join("\n")
    end

    # Re-write all enabled asset URLs in a stylesheet with their corresponding
    # Data-URI Base-64 encoded asset contents.
    def with_data_uris(css)
      css.gsub(EMBED_REPLACER) do |url|
        "url(\"data:#{mime_type($1)};charset=utf-8;base64,#{encoded_contents($1)}\")"
      end
    end

    # Re-write all enabled asset URLs in a stylesheet with the MHTML equivalent.
    # The newlines ("\r\n") in the following method are critical. Without them
    # your MHTML will look identical, but won't work.
    def with_mhtml(css, asset_url)
      paths, index = {}, 0
      css = css.gsub(EMBED_REPLACER) do |url|
        i = paths[$1] ||= "#{index += 1}-#{File.basename($1)}"
        "url(mhtml:#{asset_url}!#{i})"
      end
      mhtml = paths.sort.map do |path, identifier|
        mime, contents = mime_type(path), encoded_contents(path)
        [MHTML_SEPARATOR, "Content-Location: #{identifier}\r\n", "Content-Type: #{mime}\r\n", "Content-Transfer-Encoding: base64\r\n\r\n", contents, "\r\n"]
      end
      [MHTML_START, mhtml, MHTML_END, css].flatten.join('')
    end

    # Return a rewritten asset URL for a new stylesheet -- the asset should
    # be tagged for embedding if embeddable, and referenced at the correct level
    # if relative.
    def construct_asset_path(asset_path, css_path, variant)
      public_path = absolute_path(asset_path, css_path)
      return "__EMBED__#{public_path}" if embeddable?(public_path, variant)
      source = asset_path.absolute? ? asset_path.to_s : relative_path(public_path)
      rewrite_asset_path(source, public_path)
    end

    # Get the site-absolute public path for an asset file path that may or may
    # not be relative, given the path of the stylesheet that contains it.
    def absolute_path(asset_pathname, css_pathname)
      (asset_pathname.absolute? ?
        Pathname.new(File.join(PUBLIC_ROOT, asset_pathname)) :
        css_pathname.dirname + asset_pathname).cleanpath
    end

    # CSS assets that are referenced by relative paths, and are *not* being
    # embedded, must be rewritten relative to the newly-merged stylesheet path.
    def relative_path(absolute_path)
      File.join('../', absolute_path.sub(PUBLIC_ROOT, ''))
    end

    # Similar to the AssetTagHelper's method of the same name, this will
    # append the RAILS_ASSET_ID cache-buster to URLs, if it's defined.
    def rewrite_asset_path(path, file_path)
      asset_id = rails_asset_id(file_path)
      (!asset_id || asset_id == '') ? path : "#{path}?#{asset_id}"
    end

    # Similar to the AssetTagHelper's method of the same name, this will
    # determine the correct asset id for a file.
    def rails_asset_id(path)
      asset_id = ENV["RAILS_ASSET_ID"]
      return asset_id if asset_id
      File.exists?(path) ? File.mtime(path).to_i.to_s : ''
    end

    # An asset is valid for embedding if it exists, is less than 32K, and is
    # stored somewhere inside of a folder named "embed". IE does not support
    # Data-URIs larger than 32K, and you probably shouldn't be embedding assets
    # that large in any case. Because we need to check the base64 length here,
    # save it so that we don't have to compute it again later.
    def embeddable?(asset_path, variant)
      font = EMBED_FONTS.include?(asset_path.extname)
      return false unless variant
      return false unless asset_path.to_s.match(EMBEDDABLE) && asset_path.exist?
      return false unless EMBED_EXTS.include?(asset_path.extname)
      return false unless font || encoded_contents(asset_path).length < MAX_IMAGE_SIZE
      return false if font && variant == :mhtml
      return true
    end

    # Return the Base64-encoded contents of an asset on a single line.
    def encoded_contents(asset_path)
      return @asset_contents[asset_path] if @asset_contents[asset_path]
      data = read_binary_file(asset_path)
      @asset_contents[asset_path] = Base64.encode64(data).gsub(/\n/, '')
    end

    # Grab the mime-type of an asset, by filename.
    def mime_type(asset_path)
      EMBED_MIME_TYPES[File.extname(asset_path)]
    end

    # Concatenate together a list of asset files.
    def concatenate(paths)
      [paths].flatten.map {|p| read_binary_file(p) }.join("\n")
    end

    # `File.read`, but in "binary" mode.
    def read_binary_file(path)
      File.open(path, 'r:binary') {|f| f.read }
    end
  end

end
