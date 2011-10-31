require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def initialize(options={})
        @options = options
        super(options)
      end

      def autolink(link, type)
        auto_link(link, :link => :urls, :html => { :target => "_blank" })
      end

      def postprocess(full_document)
        if @options[:localize_diaspora_urls] && @options[:remote_pod_url]
          localize_diaspora_url(full_document)
        else
          full_document
        end
      end

      def localize_diaspora_url(full_document)
        base_url = "https://#{@options[:remote_pod_url]}/posts/"
        full_document.gsub(/#{base_url}([0-9a-z]*)/) { |url|
          guid = $1
          if guid.length>8 and Post.exists?(:guid => guid)
            "https://#{AppConfig[:pod_url]}/posts/"+guid
          else
            url
          end
        }
      end

    end
  end
end
