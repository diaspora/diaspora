#custom filters for Octopress
require './plugins/pygments_code'

module OctopressFilters
  include HighlightCode
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

  # for Github style codeblocks eg.
  # ``` ruby
  #     code snippet
  # ```
  def backtick_codeblock(input)
    code = nil
    # Markdown support
    input = input.gsub /<p>`{3}\s*(\w+)?<\/p>\s*<pre><code>\s*(.+?)\s*<\/code><\/pre>\s*<p>`{3}<\/p>/m do
      lang = $1
      if lang != ''
        str  = $2.gsub('&lt;','<').gsub('&gt;','>').gsub('&amp;','&')
        code = highlight(str, lang)
        "<figure role=code>#{code}</figure>"
      else
        code = tableize_code($2)
        "<figure role=code>#{code}</figure>"
      end
    end

    # Textile warning
    input = input.gsub /<p>`{3}\s*(\w+)?<br\s*\/>\n(.+?)`{3}<\/p>/m do
      lang = $1
      "<pre><code>Back tick code blocks are not supported for Textile.\nTry HTML or Markdown instead or use the codeblock tag.\n\n{% codeblock #{lang} %}\nYour code snippet\n{% endcodeblock %}</code></pre>"
    end

    # Regular HTML support
    input.gsub /^`{3}\s*(\w+)?\n(.+?)\n`{3}/m do
      lang = $1
      str  = $2.gsub(/^\s{4}/, '')
      if lang != ''
        code = highlight(str, lang)
        "<figure role=code>#{code}</figure>"
      else
        code = tableize_code($2.gsub('<','&lt;').gsub('>','&gt;'))
        "<figure role=code>#{code}</figure>"
      end
    end
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

  # replaces primes with smartquotes using RubyPants
  def smart_quotes(input)
    require 'rubypants'
    RubyPants.new(input).to_html
  end

  # Returns a title cased string based on John Gruber's title case http://daringfireball.net/2008/08/title_case_update
  def titlecase(input)
    input.titlecase
  end

  # Returns a datetime if the input is a string
  def datetime(date)
    if date.class == String
      date = Time.parse(date)
    end
    date
  end

  # Returns an ordidinal date eg July 22 2007 -> July 22nd 2007
  def ordinalize(date)
    date = datetime(date)
    "#{date.strftime('%b')} #{ordinal(date.strftime('%e').to_i)}, #{date.strftime('%Y')}"
  end

  # Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
  def ordinal(number)
    if (11..13).include?(number.to_i % 100)
      "#{number}<span>th</span>"
    else
      case number.to_i % 10
      when 1; "#{number}<span>st</span>"
      when 2; "#{number}<span>nd</span>"
      when 3; "#{number}<span>rd</span>"
      else    "#{number}<span>th</span>"
      end
    end
  end
end
Liquid::Template.register_filter OctopressFilters

