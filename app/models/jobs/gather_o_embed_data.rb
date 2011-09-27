#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

module Jobs
  class GatherOEmbedData < Base
    @queue = :http_service

    class GatherOEmbedRenderer < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def isHttp?(url)
        URI.parse(url).scheme.downcase == 'http'
      end

      def autolink(link, type)
        url = auto_link(link, :link => :urls).scan(/href=["']?((?:.(?!["']?\s+(?:\S+)=|[>"']))+.)["']?/).first.first
        url = CGI::unescapeHTML(url)

        return url if OEmbedCache.exists?(:url => url) or not isHttp?(url)
        
        begin
          res = ::OEmbed::Providers.get(url, {:maxwidth => 420, :maxheight => 420, :frame => 1, :iframe => 1})
        rescue Exception => e
          # noop
        else
          data = res.fields
          data['trusted_endpoint_url'] = res.provider.endpoint
          cache = OEmbedCache.new(:url => url, :data => data)
          cache.save
        end
        
        return url
      end
    end

    def self.perform(text)
      renderer = GatherOEmbedRenderer.new({})
      markdown = Redcarpet::Markdown.new(renderer, {:autolink => true})
      message = markdown.render(text)
    end
  end
end
