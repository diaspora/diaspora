require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def autolink(link, type)
        domain_only = link[ %r{^https?://([a-zA-Z0-9.-]+/).+}, 1 ]
        auto_link(
          link,
          :link => :urls,
          :html => { :target => "_blank", :title => domain_only ? link : nil }
        ) do |text|
          domain_only ? "#{domain_only}..." : text
        end
      end

    end
  end
end
