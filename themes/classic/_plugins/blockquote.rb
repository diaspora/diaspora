#
# Author: Brandon Mathis
# Based on the work of: Josediaz Gonzalez - https://github.com/josegonzalez/josediazgonzalez.com/blob/master/_plugins/blockquote.rb
#
require './_plugins/titlecase.rb'
module Jekyll

  # Outputs a string with a given attribution as a quote
  #
  #   {% blockquote Bobby Willis http://google.com/blah the search for bobby's mom %}
  #   Wheeee!
  #   {% endblockquote %}
  #   ...
  #   <blockquote>
  #     <p>Wheeee!</p>
  #     <footer>
  #     <strong>John Paul Jones</strong><cite><a href="http://google.com/blah">The Search For Bobby's Mom</a>
  #   </blockquote>
  #
  class Blockquote < Liquid::Block
    FullCiteWithTitle = /([\w\s]+)(https?:\/\/)(\S+\s)([\w\s]+)/i
    FullCite = /([\w\s]+)(https?:\/\/)(\S+)/i
    Author =  /([\w\s]+)/

    def initialize(tag_name, markup, tokens)
      @by = nil
      @source = nil
      @title = nil
      if markup =~ FullCiteWithTitle
        @by = $1
        @source = $2 + $3
        @title = $4.titlecase
      elsif markup =~ FullCite
        @by = $1
        @source = $2 + $3
      elsif markup =~ Author
        @by = $1
      end
      super
    end

    def render(context)
      output = super
      author = "<strong>#{@by}</strong>"
      cite = "<cite><a class='source' href='#{@source}'>#{(@title || 'source')}</a></cite>"
      reply = if @by.nil?
        "<p>#{output.join.gsub(/\n\n/, '</p><p>')}</p>"
      elsif !@source.nil?
        "<p>#{output.join.gsub(/\n\n/, '</p><p>')}</p><footer>#{author + cite}</footer>"
      else
        "<p>#{output.join.gsub(/\n\n/, '</p><p>')}</p><footer>#{author}</footer>"
      end
      "<blockquote>#{reply}</blockquote>"
    end
  end
end

Liquid::Template.register_tag('blockquote', Jekyll::Blockquote)
