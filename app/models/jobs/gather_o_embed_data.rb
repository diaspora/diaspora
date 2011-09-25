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

      def autolink(link, type)
        return link if OEmbedCache.exists?(:url => link)
        
        begin
          res = ::OEmbed::Providers.get(link, {:maxwidth => 420, :maxheight => 420, :frame => 1, :iframe => 1})
        rescue Exception => e
          # noop
        else
          data = res.fields
          data['trusted_endpoint_url'] = res.provider.endpoint
          cache = OEmbedCache.new(:url => link, :data => data)
          cache.save
        end
        
        return link
      end
    end

    def self.perform(text)
      renderer = GatherOEmbedRenderer.new({})
      markdown = Redcarpet::Markdown.new(renderer, {:autolink => true})
      message = markdown.render(text)
    end
  end
end
