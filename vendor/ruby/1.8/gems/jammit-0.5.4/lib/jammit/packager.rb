module Jammit

  # The Jammit::Packager resolves the configuration file into lists of real
  # assets that get merged into individual asset packages. Given the compiled
  # contents of an asset package, the Packager knows how to cache that package
  # with the correct timestamps.
  class Packager

    # In Rails, the difference between a path and an asset URL is "public".
    PATH_DIFF   = PUBLIC_ROOT.sub(ASSET_ROOT, '')
    PATH_TO_URL = /\A#{Regexp.escape(ASSET_ROOT)}(\/?#{Regexp.escape(PATH_DIFF)})?/

    # Set force to false to allow packages to only be rebuilt when their source
    # files have changed since the last time their package was built.
    attr_accessor :force

    # Creating a new Packager will rebuild the list of assets from the
    # Jammit.configuration. When assets.yml is being changed on the fly,
    # create a new Packager.
    def initialize
      @compressor = Compressor.new
      @force = false
      @config = {
        :css => (Jammit.configuration[:stylesheets] || {}),
        :js  => (Jammit.configuration[:javascripts] || {})
      }
      @packages = {
        :css => create_packages(@config[:css]),
        :js  => create_packages(@config[:js])
      }
    end

    # Ask the packager to precache all defined assets, along with their gzip'd
    # versions. In order to prebuild the MHTML stylesheets, we need to know the
    # base_url, because IE only supports MHTML with absolute references.
    # Unless forced, will only rebuild assets whose source files have been
    # changed since their last package build.
    def precache_all(output_dir=nil, base_url=nil)
      output_dir ||= File.join(PUBLIC_ROOT, Jammit.package_path)
      cacheable(:js, output_dir).each  {|p| cache(p, 'js',  pack_javascripts(p), output_dir) }
      cacheable(:css, output_dir).each do |p|
        cache(p, 'css', pack_stylesheets(p), output_dir)
        if Jammit.embed_assets
          cache(p, 'css', pack_stylesheets(p, :datauri), output_dir, :datauri)
          if Jammit.mhtml_enabled && base_url
            mtime = Time.now
            asset_url = "#{base_url}#{Jammit.asset_url(p, :css, :mhtml, mtime)}"
            cache(p, 'css', pack_stylesheets(p, :mhtml, asset_url), output_dir, :mhtml, mtime)
          end
        end
      end
    end

    # Caches a single prebuilt asset package and gzips it at the highest
    # compression level. Ensures that the modification time of both both
    # variants is identical, for web server caching modules, as well as MHTML.
    def cache(package, extension, contents, output_dir, suffix=nil, mtime=Time.now)
      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
      raise OutputNotWritable, "Jammit doesn't have permission to write to \"#{output_dir}\"" unless File.writable?(output_dir)
      files = []
      files << file_name = File.join(output_dir, Jammit.filename(package, extension, suffix))
      File.open(file_name, 'wb+') {|f| f.write(contents) }
      if Jammit.gzip_assets
        files << zip_name = "#{file_name}.gz"
        Zlib::GzipWriter.open(zip_name, Zlib::BEST_COMPRESSION) {|f| f.write(contents) }
      end
      File.utime(mtime, mtime, *files)
    end

    # Get the list of individual assets for a package.
    def individual_urls(package, extension)
      package_for(package, extension)[:urls]
    end

    # Return the compressed contents of a stylesheet package.
    def pack_stylesheets(package, variant=nil, asset_url=nil)
      @compressor.compress_css(package_for(package, :css)[:paths], variant, asset_url)
    end

    # Return the compressed contents of a javascript package.
    def pack_javascripts(package)
      @compressor.compress_js(package_for(package, :js)[:paths])
    end

    # Return the compiled contents of a JST package.
    def pack_templates(package)
      @compressor.compile_jst(package_for(package, :js)[:paths])
    end

    private

    # Look up a package asset list by name, raising an exception if the
    # package has gone missing.
    def package_for(package, extension)
      pack = @packages[extension] && @packages[extension][package]
      pack || not_found(package, extension)
    end

    # Absolute globs are absolute -- relative globs are relative to ASSET_ROOT.
    # Print a warning if no files were found that match the glob.
    def glob_files(glob)
      absolute = Pathname.new(glob).absolute?
      paths = Dir[absolute ? glob : File.join(ASSET_ROOT, glob)].sort
      Jammit.warn("No assets match '#{glob}'") if paths.empty?
      paths
    end

    # Return a list of all of the packages that should be cached. If "force" is
    # true, this is all of them -- otherwise only the packages that are missing
    # or whose source files have changed since the last package build.
    def cacheable(extension, output_dir)
      names = @packages[extension].keys
      return names if @force
      config_mtime = File.mtime(Jammit.config_path)
      return names.select do |name|
        pack        = package_for(name, extension)
        cached      = [Jammit.filename(name, extension)]
        cached.push Jammit.filename(name, extension, :datauri) if Jammit.embed_assets
        cached.push Jammit.filename(name, extension, :mhtml) if Jammit.mhtml_enabled
        cached.map! {|file| File.join(output_dir, file) }
        if cached.any? {|file| !File.exists?(file) }
          true
        else
          since = cached.map {|file| File.mtime(file) }.min
          config_mtime > since || pack[:paths].any? {|src| File.mtime(src) > since }
        end
      end
    end

    # Compiles the list of assets that goes into each package. Runs an
    # ordered list of Dir.globs, taking the merged unique result.
    # If there are JST files in this package we need to add an extra
    # path for when package_assets is off (e.g. in a dev environment).
    # This package (e.g. /assets/package-name.jst) will never exist as
    # an actual file but will be dynamically generated by Jammit on
    # every request.
    def create_packages(config)
      packages = {}
      return packages if !config
      config.each do |name, globs|
        globs                  ||= []
        packages[name]         = {}
        paths                  = globs.flatten.uniq.map {|glob| glob_files(glob) }.flatten.uniq
        packages[name][:paths] = paths
        if !paths.grep(Jammit.template_extension_matcher).empty?
          packages[name][:urls] = paths.grep(JS_EXTENSION).map {|path| path.sub(PATH_TO_URL, '') }
          packages[name][:urls] += [Jammit.asset_url(name, Jammit.template_extension)]
        else
          packages[name][:urls] = paths.map {|path| path.sub(PATH_TO_URL, '') }
        end
      end
      packages
    end

    # Raise a PackageNotFound exception for missing packages...
    def not_found(package, extension)
      raise PackageNotFound, "assets.yml does not contain a \"#{package}\" #{extension.to_s.upcase} package"
    end

  end

end
