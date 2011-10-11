require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def autolink(link, type)
        auto_link(link, :link => :urls, :html => { :target => "_blank" })
      end
    end

    class HTMLwithOEmbed < Redcarpet::Render::HTML
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::RawOutputHelper

      def autolink(link, type)
        #auto_link(link, :link => :urls, :html => { :target => "_blank" })

        title = link
        url = auto_link(link, :link => :urls).scan(/href=["']?((?:.(?!["']?\s+(?:\S+)=|[>"']))+.)["']?/).first.first
        url = CGI::unescapeHTML(url)

        cache = OEmbedCache.find_by_url(url)
        if not cache.nil? and cache.data.has_key?('type')
          case cache.data['type']
          when 'video', 'rich'
              if SECURE_ENDPOINTS.include?(cache.data['trusted_endpoint_url']) and cache.data.has_key?('html')
                rep = raw(cache.data['html'])
              elsif cache.data.has_key?('thumbnail_url')
                img_options = {}
                img_options.merge!({:height => cache.data['thumbnail_height'],
                                    :width  => cache.data['thumbnail_width']}) if cache.data.has_key?('thumbnail_width') and cache.data.has_key?('thumbnail_height')
                img_options[:alt] = cache.data['title'] if cache.data.has_key?('title')
                rep = link_to(image_tag(cache.data['thumbnail_url'], img_options),
                              url, :target => '_blank')
              end

          when 'photo'
              if cache.data.has_key?('url')
                img_options = {}
                img_options.merge!({:height => cache.data['height'],
                                    :width  => cache.data['width']}) if cache.data.has_key?('width') and cache.data.has_key?('height')
                img_options[:alt] = cache.data['title'] if cache.data.has_key?('title')
                rep = link_to(image_tag(cache.data['url'], img_options),
                              url, :target => '_blank')
            end
          else
            puts "mega derp"
          end

          title = cache.data['title'] \
                                     if cache.data.has_key?('title') and \
                                     not cache.data['title'].blank?
        end

        rep ||= link_to(title, url, :target => '_blank') if rep.blank?
        return rep
      end
    end
>>>>>>> wip
  end
end
