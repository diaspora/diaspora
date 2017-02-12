
class BookmarkletRenderer
  class << self
    def cached_name
      @cached ||= Rails.root.join("public", "assets", "bookmarklet.js")
    end

    def source_name
      @source ||= Rails.application.assets["bookmarklet.js"].pathname.to_s
    end

    def body
      if !File.exist?(cached_name) && Rails.env.production?
        raise "please run the Rake task to compile the bookmarklet: `bundle exec rake assets:uglify_bookmarklet`"
      end

      compile unless Rails.env.production? # don't make me re-run rake in development
      @body ||= File.read(cached_name)
    end

    def compile
      src = File.read(source_name)
      @body = Uglifier.compile(src)
      FileUtils.mkdir_p cached_name.dirname
      File.open(cached_name, "w") {|f| f.write(@body) }
    end
  end
end
