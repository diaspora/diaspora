# Title: Simple Code Blocks for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Write codeblocks with semantic HTML5 <figure> and <figcaption> elements and optional syntax highlighting — all with a simple, intuitive interface.
#
# Syntax:
# {% codeblock [title] [url] [link text] %}
# code snippet
# {% endcodeblock %}
#
# For syntax highlighting, put a file extension somewhere in the title. examples:
# {% codeblock file.sh %}
# code snippet
# {% endcodeblock %}
#
# {% codeblock Time to be Awesome! (awesome.rb) %}
# code snippet
# {% endcodeblock %}
#
# Example:
#
# {% codeblock Got pain? painreleif.sh http://site.com/painreleief.sh Download it! %}
# $ rm -rf ~/PAIN
# {% endcodeblock %}
#
# Output:
#
# <figure role=code>
# <figcaption><span>Got pain? painrelief.sh</span> <a href="http://site.com/painrelief.sh">Download it!</a>
# <div class="highlight"><pre><code class="sh">
# -- nicely escaped highlighted code --
# </code></pre></div>
# </figure>
#
# Example 2 (no syntax highlighting):
#
# {% codeblock %}
# <sarcasm>Ooooh, sarcasm... How original!</sarcasm>
# {% endcodeblock %}
#
# <figure role=code>
# <pre><code>&lt;sarcasm> Ooooh, sarcasm... How original!&lt;/sarcasm></code></pre>
# </figure>
#
require './plugins/pygments_code'

module Jekyll

  class CodeBlock < Liquid::Block
    include HighlightCode
    CaptionUrlTitle = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)\s+(.+)/i
    CaptionUrl = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)/i
    Caption = /(\S[\S\s]*)/
    def initialize(tag_name, markup, tokens)
      @title = nil
      @caption = nil
      @highlight = true
      if markup =~ CaptionUrlTitle
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>#{$4}</a></figcaption>"
      elsif markup =~ CaptionUrl
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>link</a></figcaption>"
      elsif markup =~ Caption
        @file = $1
        @caption = "<figcaption><span>#{$1}</span></figcaption>\n"
      end
      if @file =~ /\S[\S\s]*\.(\w+)/
        @filetype = $1
      end
      super
    end

    def render(context)
      output = super
      code = super.join
      source = "<div><figure role=code>"
      source += @caption if @caption
      source = context['pygments_prefix'] + source if context['pygments_prefix']
      if @filetype
        @filetype = 'objc' if @filetype == 'm'
        @filetype = 'perl' if @filetype == 'pl'
        @filetype = 'yaml' if @filetype == 'yml'
        source += " #{highlight(code, @filetype)}</figure></div>"
      else
        source += "<pre><code>" + code.lstrip.rstrip.gsub(/</,'&lt;') + "</code></pre></figure></div>"
      end
      source = source + context['pygments_suffix'] if context['pygments_suffix']
    end
  end
end

Liquid::Template.register_tag('codeblock', Jekyll::CodeBlock)
