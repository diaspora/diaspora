# Title: Simple Image Figure tag for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Easily output images in <figure> with an optional <figcaption> and class names.
#
# Syntax {% figure [class name(s)] url [caption text] %}
#
# Example:
# {% figure left half http://site.com/images/ninja.png Ninja Attack! %}
#
# Output:
# <figure class='left half'><img src="http://site.com/images/ninja.png"><figcaption>Ninja Attack!</figcaption></figure>
#
# Example 2 (image with caption)
# {% figure /images/ninja.png Ninja Attack! %}
#
# Output:
# <figure><img src="/images/ninja.png"><figcaption>Ninja Attack!</figcaption></figure>
#
# Example 3 (just an image with classes)
# {% figure right /images/ninja.png %}
#
# Output:
# <figure><img class="right" src="/images/ninja.png"></figure>
#

module Jekyll

  class FigureImageTag < Liquid::Tag
    ClassImgCaption = /(\S[\S\s]*)\s+(https?:\/\/|\/)(\S+)\s+(.+)/i
    ClassImg = /(\S[\S\s]*)\s+(https?:\/\/|\/)(\S+)/i
    ImgCaption = /^\s*(https?:\/\/|\/)(\S+)\s+(.+)/i
    Img = /^\s*(https?:\/\/|\/)(\S+\s)/i

    @img = nil
    @caption = nil
    @class = ''

    def initialize(tag_name, markup, tokens)
      if markup =~ ClassImgCaption
        @class = $1
        @img = $2 + $3
        @caption = $4
      elsif markup =~ ClassImg
        @class = $1
        @img = $2 + $3
      elsif markup =~ ImgCaption
        @img = $1 + $2
        @caption = $3
      elsif markup =~ Img
        @img = $1 + $2
      end
      super
    end

    def render(context)
      output = super
      if @img
        figure =  "<figure class='#{@class}'>"
        figure += "<img src='#{@img}'>"
        figure += "<figcaption>#{@caption}</figcaption>" if @caption
        figure += "</figure>"
      else
        "Error processing input, expected syntax: {% figure [class name(s)] /url/to/image [caption] %}"
      end
    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::FigureImageTag)
