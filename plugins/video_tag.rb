# Title: Simple Video tag for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Easily output MPEG4 HTML5 video with a flash backup.
#
# Syntax {% video url/to/video [width height] [url/to/poster] %}
#
# Example:
# {% video http://site.com/video.mp4 720 480 http://site.com/poster-frame.jpg %}
#
# Output:
# <video width='720' height='480' preload='none' controls poster='http://site.com/poster-frame.jpg'>
#   <source src='http://site.com/video.mp4' type='video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\"'/>
# </video>
#

module Jekyll

  class VideoTag < Liquid::Tag
    @video = nil
    @poster = ''
    @height = ''
    @width = ''

    def initialize(tag_name, markup, tokens)
      if markup =~ /((https?:\/\/|\/)(\S+))(\s+(\d+)\s(\d+))?(\s+(https?:\/\/|\/)(\S+))?/i
        @video  = $1
        @width  = $5
        @height = $6
        @poster = $7
      end
      super
    end

    def render(context)
      output = super
      if @video
        video =  "<video width='#{@width}' height='#{@height}' preload='none' controls poster='#{@poster}'>"
        video += "<source src='#{@video}' type='video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\"'/></video>"
      else
        "Error processing input, expected syntax: {% video url/to/video [width height] [url/to/poster] %}"
      end
    end
  end
end

Liquid::Template.register_tag('video', Jekyll::VideoTag)

