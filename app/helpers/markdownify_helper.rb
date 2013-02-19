#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module MarkdownifyHelper
  def markdownify(target, render_options={})

    markdown_options = {
      :autolink            => true,
      :fenced_code_blocks  => true,
      :space_after_headers => true,
      :strikethrough       => true,
      :tables              => true,
      :no_intra_emphasis   => true,
    }

    render_options[:filter_html] = true
    render_options[:hard_wrap] ||= true
    render_options[:safe_links_only] = true

    # This ugly little hack basically means
    #   "Give me the rawest contents of target available"
    if target.respond_to?(:raw_message)
      message = target.raw_message
    elsif target.respond_to?(:text)
      message = target.text
    else
      message = target.to_s
    end

    return '' if message.blank?

    renderer = Diaspora::Markdownify::HTML.new(render_options)
    markdown = Redcarpet::Markdown.new(renderer, markdown_options)

    message = markdown.render(message).html_safe

    if target.respond_to?(:format_mentions)
      message = target.format_mentions(message)
    end

    message = Diaspora::Taggable.format_tags(message, :no_escape => true)

    return message.html_safe
  end
  
  def strip_markdown(text)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::StripDown, :autolink => true)
    renderer.render(text)
  end

  def process_newlines(message)
    # in very clear cases, let newlines become <br /> tags
    # Grabbed from Github flavored Markdown
    message.gsub(/^[\w\<][^\n]*\n+/) do |x|
      x =~ /\n{2}/ ? x : (x.strip!; x << " \n")
    end
  end
end
