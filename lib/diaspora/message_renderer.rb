# frozen_string_literal: true

module Diaspora
  # Takes a raw message text and converts it to
  # various desired target formats, respecting
  # all possible formatting options supported
  # by Diaspora
  class MessageRenderer
    class Processor
      class << self
        private :new

        def process message, options, &block
          return '' if message.blank? # Optimize for empty message
          processor = new message, options
          processor.instance_exec(&block)
          processor.message
        end

        def normalize message
          message.gsub(/[\u202a\u202b]#[\u200e\u200f\u202d\u202e](\S+)\u202c/u, "#\\1")
        end
      end

      attr_reader :message, :options

      def initialize message, options
        @message = message
        @options = options
      end

      def squish
        @message = message.squish if options[:squish]
      end

      def append_and_truncate
        if options[:truncate]
          # TODO: Remove .dup when upgrading to Rails 6.x.
          @message = @message.truncate(options[:truncate] - options[:append].to_s.size).dup
        end

        @message << options[:append].to_s
        @message << options[:append_after_truncate].to_s
      end

      def escape
        if options[:escape]
          @message = ERB::Util.html_escape_once message
        end
      end

      def strip_markdown
        renderer = Redcarpet::Markdown.new Redcarpet::Render::StripDown, options[:markdown_options]
        @message = renderer.render(message).strip
      end

      def markdownify
        renderer = Diaspora::Markdownify::HTML.new options[:markdown_render_options]
        markdown = Redcarpet::Markdown.new renderer, options[:markdown_options]

        @message = markdown.render message
      end

      # In very clear cases, let newlines become <br /> tags
      # Grabbed from Github flavored Markdown
      def process_newlines
        message.gsub(/^[\w\<][^\n]*\n+/) do |x|
          x =~ /\n{2}/ ? x : (x.strip!; x << " \n")
        end
      end

      def render_mentions
        unless options[:disable_hovercards] || options[:mentioned_people].empty?
          @message = Diaspora::Mentionable.format message, options[:mentioned_people]
        end

        if options[:disable_hovercards] || options[:link_all_mentions]
          @message = Diaspora::Mentionable.filter_people message, []
        else
          make_mentions_plain_text
        end
      end

      def make_mentions_plain_text
        @message = Diaspora::Mentionable.format message, options[:mentioned_people], plain_text: true
      end

      def render_tags
        @message = Diaspora::Taggable.format_tags message, no_escape: !options[:escape_tags]
      end

      def camo_urls
        @message = Diaspora::Camo.from_markdown(@message)
      end

      def normalize
        @message = self.class.normalize(@message)
      end

      def diaspora_links
        @message = @message.gsub(DiasporaFederation::Federation::DiasporaUrlParser::DIASPORA_URL_REGEX) {|match_str|
          guid = Regexp.last_match(3)
          Regexp.last_match(2) == "post" && Post.exists?(guid: guid) ? AppConfig.url_to("/posts/#{guid}") : match_str
        }
      end
    end

    DEFAULTS = {mentioned_people: [],
                link_all_mentions: false,
                disable_hovercards: false,
                truncate: false,
                append: nil,
                append_after_truncate: nil,
                squish: false,
                escape: true,
                escape_tags: false,
                markdown_options: {
                  autolink: true,
                  fenced_code_blocks:  true,
                  space_after_headers: true,
                  strikethrough: true,
                  tables: true,
                  no_intra_emphasis: true,
                },
                markdown_render_options: {
                  filter_html: true,
                  hard_wrap: true,
                  safe_links_only: true
                }}.freeze

    delegate :empty?, :blank?, :present?, to: :raw

    # @param [String] text Raw input text
    # @param [Hash] opts Global options affecting output
    # @option opts [Array<Person>] :mentioned_people ([]) List of people
    #   allowed to mention
    # @option opts [Boolean] :link_all_mentions (false) Whether to link
    #   all mentions. This makes plain links to profiles for people not in
    #   :mentioned_people
    # @option opts [Boolean] :disable_hovercards (true) Render all mentions
    #   as profile links. This implies :link_all_mentions and ignores
    #   :mentioned_people
    # @option opts [#to_i, Boolean] :truncate (false) Truncate message to
    #   the specified length
    # @option opts [String] :append (nil) Append text to the end of
    #   the (truncated) message, counts into truncation length
    # @option opts [String] :append_after_truncate (nil) Append text to the end
    #   of the (truncated) message, doesn't count into the truncation length
    # @option opts [Boolean] :squish (false) Squish the message, that is
    #   remove all surrounding and consecutive whitespace
    # @option opts [Boolean] :escape (true) Escape HTML relevant characters
    #   in the message. Note that his option is ignored in the plaintext
    #   renderers.
    # @option opts [Boolean] :escape_tags (false) Escape HTML relevant
    #   characters in tags when rendering them
    # @option opts [Hash] :markdown_options Override default options passed
    #   to Redcarpet
    # @option opts [Hash] :markdown_render_options Override default options
    #   passed to the Redcarpet renderer
    def initialize(text, opts={})
      @text = text
      @options = DEFAULTS.deep_merge opts
    end

    # @param [Hash] opts Override global output options, see {#initialize}
    def plain_text opts={}
      process(opts) {
        make_mentions_plain_text
        diaspora_links
        squish
        append_and_truncate
      }
    end

    # @param [Hash] opts Override global output options, see {#initialize}
    def plain_text_without_markdown opts={}
      process(opts) {
        make_mentions_plain_text
        diaspora_links
        strip_markdown
        squish
        append_and_truncate
      }
    end

    # @param [Hash] opts Override global output options, see {#initialize}
    def plain_text_for_json opts={}
      process(opts) {
        normalize
        diaspora_links
        camo_urls if AppConfig.privacy.camo.proxy_markdown_images?
      }
    end

    # @param [Hash] opts Override global output options, see {#initialize}
    def html opts={}
      process(opts) {
        escape
        normalize
        diaspora_links
        render_mentions
        render_tags
        squish
        append_and_truncate
      }.html_safe
    end

    # @param [Hash] opts Override global output options, see {#initialize}
    def markdownified opts={}
      process(opts) {
        process_newlines
        normalize
        diaspora_links
        camo_urls if AppConfig.privacy.camo.proxy_markdown_images?
        markdownify
        render_mentions
        render_tags
        squish
        append_and_truncate
      }.html_safe
    end

    # Get a short summary of the message
    # @param [Hash] opts Additional options
    # @option opts [Integer] :length (70) Truncate the title to
    #   this length. If not given defaults to 70.
    def title opts={}
      # Setext-style header
      heading = if /\A(?<setext_content>.{1,200})\n(?:={1,200}|-{1,200})(?:\r?\n|$)/ =~ @text.lstrip
                  setext_content
                # Atx-style header
                elsif /\A\#{1,6}\s+(?<atx_content>.{1,200}?)(?:\s+#+)?(?:\r?\n|$)/ =~ @text.lstrip
                  atx_content
                end

      heading &&= self.class.new(heading).plain_text_without_markdown

      if heading
        heading.truncate opts.fetch(:length, 70)
      else
        plain_text_without_markdown squish: true, truncate: opts.fetch(:length, 70)
      end
    end

    # Extracts all the urls from the raw message and return them in the form of a string
    # Different URLs are seperated with a space
    def urls
      @urls ||= Twitter::Extractor.extract_urls(plain_text_without_markdown).map {|url|
        Addressable::URI.parse(url).normalize.to_s
      }
    end

    def raw
      @text
    end

    def to_s
      plain_text
    end

    private

    def process(opts, &block)
      Processor.process(@text, @options.deep_merge(opts), &block)
    end
  end
end
