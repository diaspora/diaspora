# Title: Render Partial Tag for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Import files on your filesystem into any blog post and render them inline.
# Note: Paths are relative to the source directory, if you import a file with yaml front matter, the yaml will be stripped out.
#
# Syntax {% render_partial path/to/file %}
#
# Example 1:
# {% render_partial about/_bio.markdown %}
#
# This will import source/about/_bio.markdown and render it inline.
# In this example I used an underscore at the beginning of the filename to prevent Jekyll
# from generating an about/bio.html (Jekyll doesn't convert files beginning with underscores)
#
# Example 2:
# {% render_partial ../README.markdown %}
#
# You can use relative pathnames, to include files outside of the source directory.
# This might be useful if you want to have a page for a project's README without having
# to duplicated the contents
#
#

require 'pathname'
require './plugins/octopress_filters'

module Jekyll

  class RenderPartialTag < Liquid::Tag
    include OctopressFilters
    def initialize(tag_name, markup, tokens)
      @file = nil
      @raw = false
      if markup =~ /^(\S+)\s?(\w+)?/
        @file = $1.strip
        @raw = $2 == 'raw'
      end
      super
    end

    def render(context)
      file_dir = (context.registers[:site].source || 'source')
      file_path = Pathname.new(file_dir).expand_path
      file = file_path + @file

      unless file.file?
        return "File #{file} could not be found"
      end

      Dir.chdir(file_path) do
        contents = file.read
        if contents =~ /\A-{3}.+[^\A]-{3}\n(.+)/m
          contents = $1.lstrip
        end
        contents = pre_filter(contents)
        if @raw
          contents
        else
          partial = Liquid::Template.parse(contents)
          context.stack do
            partial.render(context)
          end
        end
      end
    end
  end
end

Liquid::Template.register_tag('render_partial', Jekyll::RenderPartialTag)
