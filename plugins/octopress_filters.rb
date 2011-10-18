#custom filters for Octopress
require './plugins/backtick_code_block'
require './plugins/post_filters'
require './plugins/raw'
require './plugins/date'
require 'rubypants'

module OctopressFilters
  include BacktickCodeBlock
  include TemplateWrapper
  def pre_filter(input)
    input = render_code_block(input)
    input.gsub /(<figure.+?>.+?<\/figure>)/m do
      safe_wrap($1)
    end
  end
  def post_filter(input)
    input = unwrap(input)
    RubyPants.new(input).to_html
  end
end

module Jekyll
  class ContentFilters < PostFilter
    include OctopressFilters
    def pre_render(post)
      post.content = pre_filter(post.content)
    end
    def post_render(post)
      post.content = post_filter(post.content)
    end
  end
end


module OctopressLiquidFilters
  include Octopress::Date

  # Used on the blog index to split posts on the <!--more--> marker
  def excerpt(input)
    if input.index(/<!--\s*more\s*-->/i)
      input.split(/<!--\s*more\s*-->/i)[0]
    else
      input
    end
  end

  # Checks for excerpts (helpful for template conditionals)
  def has_excerpt(input)
    input =~ /<!--\s*more\s*-->/i ? true : false
  end

  # Summary is used on the Archive pages to return the first block of content from a post.
  def summary(input)
    if input.index(/\n\n/)
      input.split(/\n\n/)[0]
    else
      input
    end
  end

  # Extracts raw content DIV from template, used for page description as {{ content }}
  # contains complete sub-template code on main page level
  def raw_content(input)
    /<div class="entry-content">(?<content>[\s\S]*?)<\/div>\s*<(footer|\/article)>/ =~ input
    return (content.nil?) ? input : content
  end

  # Escapes CDATA sections in post content
  def cdata_escape(input)
    input.gsub(/<!\[CDATA\[/, '&lt;![CDATA[').gsub(/\]\]>/, ']]&gt;')
  end

  # Replaces relative urls with full urls
  def expand_urls(input, url='')
    url ||= '/'
    input.gsub /(\s+(href|src)\s*=\s*["|']{1})(\/[^\"'>]*)/ do
      $1+url+$3
    end
  end

  # Removes trailing forward slash from a string for easily appending url segments
  def strip_slash(input)
    if input =~ /(.+)\/$|^\/$/
      input = $1
    end
    input
  end

  # Returns a url without the protocol (http://)
  def shorthand_url(input)
    input.gsub /(https?:\/\/)(\S+)/ do
      $2
    end
  end

  # Returns a title cased string based on John Gruber's title case http://daringfireball.net/2008/08/title_case_update
  def titlecase(input)
    input.titlecase
  end

end
Liquid::Template.register_filter OctopressLiquidFilters

