#
# Author: Josediaz Gonzalez - https://github.com/josegonzalez
# Source URL: https://github.com/josegonzalez/josediazgonzalez.com/blob/master/_plugins/blockquote.rb
# Modified by Brandon Mathis
#
require './_plugins/titlecase.rb'
module Jekyll

  # Outputs a string with a given attribution as a quote
  #
  #   {% blockquote John Paul Jones %}
  #     Monkeys!
  #   {% endblockquote %}
  #   ...
  #   <blockquote>
  #     Monkeys!
  #     <br />
  #     John Paul Jones
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
      if @by.nil?
        '<blockquote><p>' + output.join + '</p></blockquote>'
      elsif !@title.nil?
        '<blockquote><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong>' + '<a class="source" href="' + @source + '">' + @title + '</a></cite></p>'
      elsif !@source.nil?
        '<blockquote><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong>' + '<a class="source" href="' + @source + '">source</a></cite></p>'
      else
        '<blockquote><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong></cite></p>'
      end
    end
  end

  # Outputs a string with a given attribution as a pullquote
  #
  #   {% blockquote John Paul Jones %}
  #     Monkeys!
  #   {% endblockquote %}
  #   ...
  #   <blockquote class="pullquote">
  #     Monkeys!
  #     <br />
  #     John Paul Jones
  #   </blockquote>
  #
  class Pullquote < Liquid::Block
    FullCiteWithTitle = /([\w\s]+)(http:\/\/|https:\/\/)(\S+)([\w\s]+)/i
    FullCite = /([\w\s]+)(http:\/\/|https:\/\/)(\S+)/i
    Author =  /([\w\s]+)/

    def initialize(tag_name, markup, tokens)
      @by = nil
      @source = nil
      @title = nil
      if markup =~ FullCiteWithTitle
        @by = $1
        @source = $2 + $3
        @title = $4
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
      if @by.nil?
        '<blockquote class="pullquote"><p>' + output.join + '</p></blockquote>'
      elsif @title
        '<blockquote class="pullquote"><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong>' + ' <a class="source" href="' + @source + '">' + @title + '</a></cite></p>'
      elsif @source
        '<blockquote class="pullquote"><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong>' + ' <a class="source" href="' + @source + '">source</a></cite></p>'
      elsif @by
        '<blockquote class="pullquote"><p>' + output.join + '</p></blockquote>' + '<p><cite><strong>' + @by + '</strong></cite></p>'
      end
    end
  end
end

Liquid::Template.register_tag('blockquote', Jekyll::Blockquote)
Liquid::Template.register_tag('pullquote', Jekyll::Pullquote)


