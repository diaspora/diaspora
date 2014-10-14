module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper

      def autolink link, type
        Twitter::Autolink.auto_link_urls(link, url_target: "_blank")
      end
    end
  end
end
