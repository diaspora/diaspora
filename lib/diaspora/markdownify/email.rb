module Diaspora
  module Markdownify
    class Email < Redcarpet::Render::HTML
      include Rails.application.routes.url_helpers
      TAG_REGEX = /(?:^|\s)#([#{ActsAsTaggableOn::Tag.tag_text_regexp}]+)/u
      def preprocess(text)
        process_tags(text)
      end

      private
      def tags(text)
        text.scan(TAG_REGEX).map { |match| match[0] }
      end

      def process_tags(text)
        return text unless text.match(TAG_REGEX)
        tags(text).each do |tag|
          text.gsub!(/##{tag}/) do |tag|
            opts = {:name => ActsAsTaggableOn::Tag.normalize(tag)}.merge(Rails.application.config.action_mailer.default_url_options)
            "[#{tag}](#{tag_url(opts)})"
          end
        end
        text
      end
    end
  end
end
