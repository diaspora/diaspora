# Jekyll sitemap page generator.
# http://recursive-design.com/projects/jekyll-plugins/
#
# Version: 0.1.3 (201101061053)
#
# Copyright (c) 2010 Dave Perrett, http://recursive-design.com/
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# A generator that creates a sitemap.xml page for jekyll sites, suitable for submission to
# google etc.
#
# To use it, simply drop this script into the _plugins directory of your Jekyll site.
#
# When you compile your jekyll site, this plugin will loop through the list of pages in your
# site, and generate an entry in sitemap.xml for each one.

require 'pathname'

module Jekyll


  # Monkey-patch an accessor for a page's containing folder, since
  # we need it to generate the sitemap.
  class Page
    def subfolder
      @dir
    end
  end


  # Sub-class Jekyll::StaticFile to allow recovery from unimportant exception
  # when writing the sitemap file.
  class StaticSitemapFile < StaticFile
    def write(dest)
      super(dest) rescue ArgumentError
      true
    end
  end


  # Generates a sitemap.xml file containing URLs of all pages and posts.
  class SitemapGenerator < Generator
    safe true
    priority :low

    # Domain that you are generating the sitemap for - update this to match your site.

    # Generates the sitemap.xml file.
    #
    #  +site+ is the global Site object.
    def generate(site)
      # Create the destination folder if necessary.
      site_folder = site.config['destination']
      unless File.directory?(site_folder)
        p = Pathname.new(site_folder)
        p.mkdir
      end

      # Write the contents of sitemap.xml.
      File.open(File.join(site_folder, 'sitemap.xml'), 'w') do |f|
        f.write(generate_header())
        f.write(generate_content(site))
        f.write(generate_footer())
        f.close
      end

      # Add a static file entry for the zip file, otherwise Site::cleanup will remove it.
      site.static_files << Jekyll::StaticSitemapFile.new(site, site.dest, '/', 'sitemap.xml')
    end

    private

    # Returns the XML header.
    def generate_header
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
    end

    # Returns a string containing the the XML entries.
    #
    #  +site+ is the global Site object.
    def generate_content(site)
      result   = ''

      base_url = site.config['url']

      # First, try to find any stand-alone pages.
      site.pages.each{ |page|
        path     = page.subfolder + '/' + page.name
        mod_date = File.mtime(site.source + path)

  			# Remove the trailing 'index.html' if there is one, and just output the folder name.
  			if path=~/index.html$/
  			  path = path[0..-11]
  		  end

        unless path =~/error/
          result += entry(base_url, path, mod_date)
        end
      }

      # Next, find all the posts.
      posts = site.site_payload['site']['posts']
      for post in posts do
        result += entry(base_url, post.id, post.date)
      end

    	result
    end

    # Returns the XML footer.
    def generate_footer
      "\n</urlset>"
    end

    # Creates an XML entry from the given path and date.
    #
    #  +path+ is the URL path to the page.
    #  +date+ is the date the file was modified (in the case of regular pages), or published (for blog posts).
    def entry(base_url, path, date)
        # Force extensions to .html from markdown, textile.
        path = path.gsub(/\.(markdown|textile)$/i, '.html')
      "
  <url>
      <loc>#{base_url}#{path}</loc>
      <lastmod>#{date.strftime("%Y-%m-%d")}</lastmod>
  </url>"
    end

  end

end


