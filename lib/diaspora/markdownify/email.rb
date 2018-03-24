# frozen_string_literal: true

module Diaspora
  module Markdownify
    class Email < Redcarpet::Render::HTML
      def preprocess(text)
        Diaspora::Taggable.format_tags_for_mail text
      end
    end
  end
end
