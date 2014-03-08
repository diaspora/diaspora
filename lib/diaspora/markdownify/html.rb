module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper

      def autolink link, type
        auto_link(link, link: :urls, html: { target: "_blank" })
      end
    end
  end
end
