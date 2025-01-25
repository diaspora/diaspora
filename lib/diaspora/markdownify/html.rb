# frozen_string_literal: true

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper

      def autolink(link, type)
        Twitter::TwitterText::Autolink.auto_link_urls(
          link,
          url_target: link.start_with?("diaspora://") ? nil : "_blank",
          link_attribute_block: lambda { |_, attr|attr[:rel] = "noopener noreferrer" unless link.start_with?("diaspora://")})
      end
      
    end
  end
end
