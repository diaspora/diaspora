require Rails.root.join("app", "models", "acts_as_taggable_on", "tag")

module Diaspora
  module Markdownify
    class Email < Redcarpet::Render::HTML
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
          text.gsub!(/##{tag}/i, "\\##{tag}")
        end
        text
      end
    end
  end
end