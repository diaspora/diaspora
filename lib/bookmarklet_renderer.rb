
# frozen_string_literal: true

class BookmarkletRenderer
  class << self
    def cached_name
      @cached_name ||= if Rails.application.config.assets.compile
                         "bookmarklet.js"
                       else
                         Rails.application.assets_manifest.assets["bookmarklet.js"]
                       end
    end

    def cached_path
      @cached_path ||= Rails.root.join("public", "assets", cached_name)
    end

    def source
      @source ||= Rails.application.assets["bookmarklet.js"].pathname.to_s
    end

    def body
      unless File.exist?(cached_path) || Rails.application.config.assets.compile
        raise "Please run the rake task to compile the bookmarklet: `bin/rake assets:precompile`"
      end

      compile if Rails.application.config.assets.compile
      @body ||= File.read(cached_path)
    end

    def compile
      src = File.read(source)
      @body = Uglifier.compile(src)
      FileUtils.mkdir_p cached_path.dirname
      File.open(cached_path, "w") {|f| f.write(@body) }
    end
  end
end
