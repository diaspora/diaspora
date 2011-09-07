#custom filters for Octopress
require './plugins/backtick_code_block'
require './plugins/post_filters'
require './plugins/raw'
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
Liquid::Template.register_filter OctopressLiquidFilters

