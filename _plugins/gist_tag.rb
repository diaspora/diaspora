# Nicked from Brandon Tilly
# Gist https://gist.github.com/803483
# Post http://brandontilley.com/2011/01/31/gist-tag-for-jekyll.html
#
# Example usage: {% gist 803483 gist_tag.rb %} //embeds a gist for this plugin

require 'digest/md5'
require 'net/https'
require 'uri'

module Jekyll
  class GistTag < Liquid::Tag
    def initialize(tag_name, text, token)
      super
      system('mkdir -p .gist_cache')
      @text         = text
      @cache        = true
      @cache_folder = File.expand_path "../.gist_cache", File.dirname(__FILE__)
    end

    def render(context)
      return "" unless @text =~ /([\d]*) (.*)/

      gist, file = $1.strip, $2.strip
      script_url = "https://gist.github.com/#{gist}.js?file=#{file}"

      code       = get_cached_gist(gist, file) || get_gist_from_web(gist, file)
      code       = code.gsub "<", "&lt;"
      string     = "<script src='#{script_url}'></script>"
      string    += "<noscript><pre><code>#{code}</code></pre></noscript>"
      return string
    end

    def get_gist_url_for(gist, file)
      "https://gist.github.com/raw/#{gist}/#{file}"
    end

    def cache_gist(gist, file, data)
      file = get_cache_file_for gist, file
      File.open(file, "w+") do |f|
        f.write(data)
      end
    end

    def get_cached_gist(gist, file)
      return nil if @cache == false
      file = get_cache_file_for gist, file
      return nil unless File.exist?(file)
      return File.new(file).readlines.join
    end

    def get_cache_file_for(gist, file)
      gist.gsub! /[^a-zA-Z0-9\-_\.]/, ''
      file.gsub! /[^a-zA-Z0-9\-_\.]/, ''
      md5 = Digest::MD5.hexdigest "#{gist}-#{file}"
      File.join @cache_folder, "#{gist}-#{file}-#{md5}.cache"
    end

    def get_gist_from_web(gist, file)
      gist_url          = get_gist_url_for(gist, file)
      raw_uri           = URI.parse(gist_url)
      https             = Net::HTTP.new(raw_uri.host, raw_uri.port)
      https.use_ssl     = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request           = Net::HTTP::Get.new(raw_uri.request_uri)
      data              = https.request(request)
      data              = data.body
      cache_gist(gist, file, data) unless @cache == false
      data
    end
  end

  class GistTagNoCache < GistTag
    def initialize(tag_name, text, token)
      super
      @cache = false
    end
  end
end

Liquid::Template.register_tag('gist', Jekyll::GistTag)
Liquid::Template.register_tag('gistnocache', Jekyll::GistTagNoCache)

