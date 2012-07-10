# Title: jsFiddle tag for Jekyll
# Author: Brian Arnold (@brianarn)
# Description:
#   Given a jsFiddle shortcode, outputs the jsFiddle iframe code.
#   Using 'default' will preserve defaults as specified by jsFiddle.
#
# Syntax: {% jsfiddle shorttag [tabs] [skin] [height] [width] %}
#
# Examples:
#
# Input: {% jsfiddle ccWP7 %}
# Output: <iframe style="width: 100%; height: 300px" src="http://jsfiddle.net/ccWP7/embedded/js,resources,html,css,result/light/"></iframe>
#
# Input: {% jsfiddle ccWP7 js,html,result %}
# Output: <iframe style="width: 100%; height: 300px" src="http://jsfiddle.net/ccWP7/embedded/js,html,result/light/"></iframe>
#

module Jekyll
  class JsFiddle < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      if /(?<fiddle>\w+)(?:\s+(?<sequence>[\w,]+))?(?:\s+(?<skin>\w+))?(?:\s+(?<height>\w+))?(?:\s+(?<width>\w+))?/ =~ markup
        @fiddle   = fiddle
        @sequence = (sequence unless sequence == 'default') || 'js,resources,html,css,result'
        @skin     = (skin unless skin == 'default') || 'light'
        @width    = width || '100%'
        @height   = height || '300px'
      end
    end

    def render(context)
      if @fiddle
        "<iframe style=\"width: #{@width}; height: #{@height}\" src=\"http://jsfiddle.net/#{@fiddle}/embedded/#{@sequence}/#{@skin}/\"></iframe>"
      else
        "Error processing input, expected syntax: {% jsfiddle shorttag [tabs] [skin] [height] [width] %}"
      end
    end
  end
end

Liquid::Template.register_tag('jsfiddle', Jekyll::JsFiddle)