#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'lib/diaspora/markdownify'

module MarkdownifyHelper
  def markdownify(message, render_options={})
    markdown_options = {
      :autolink => true,
    }

    render_options[:filter_html] = true

    renderer = Diaspora::Markdownify::HTML.new(render_options)
    markdown = Redcarpet::Markdown.new(renderer, markdown_options)
    message = markdown.render(message)
    return message.html_safe
  end

  def process_newlines(message)
    # in very clear cases, let newlines become <br /> tags
    # Grabbed from Github flavored Markdown
    message.gsub(/^[\w\<][^\n]*\n+/) do |x|
      x =~ /\n{2}/ ? x : (x.strip!; x << " \n")
    end
  end
end
