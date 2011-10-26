require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def autolink(link, type)
        auto_link(link, :link => :urls, :html => { :target => "_blank" })
      end

      def paragraph(text)
         "<p>#{text} </p>".html_safe
      end
    end
  end
end
