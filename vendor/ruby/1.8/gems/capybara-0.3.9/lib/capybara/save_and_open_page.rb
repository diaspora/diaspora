module Capybara
  module SaveAndOpenPage
    extend(self)

    def save_and_open_page(html)
      name = File.join(*[Capybara.save_and_open_page_path, "capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}.html"].compact)

      unless Capybara.save_and_open_page_path.nil? || File.directory?(Capybara.save_and_open_page_path )
        FileUtils.mkdir_p(Capybara.save_and_open_page_path)
      end
      FileUtils.touch(name) unless File.exist?(name)

      tempfile = File.new(name,'w')
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close

      open_in_browser(tempfile.path)
    end

    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy::Browser.run(path)
    rescue LoadError
      warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
    end

    def rewrite_css_and_image_references(response_html) # :nodoc:
      return response_html unless Capybara.asset_root
      directories = Dir.new(Capybara.asset_root).entries.inject([]) do |list, name|
        list << name if File.directory?(name) and not name.to_s =~ /^\./
        list
      end
      response_html.gsub(/("|')\/(#{directories.join('|')})/, '\1' + Capybara.asset_root.to_s + '/\2')
    end
  end
end
