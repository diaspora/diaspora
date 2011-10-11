#
# Author: Brandon Mathis
# Based on the semantic pullquote technique by Maykel Loomans at http://miekd.com/articles/pull-quotes-with-html5-and-css/
#
# Outputs a span with a data-pullquote attribute set from the marked pullquote. Example:
#
#   {% pullquote %} 
#     When writing longform posts, I find it helpful to include pullquotes, which help those scanning a post discern whether or not a post is helpful.
#     It is important to note, {" pullquotes are merely visual in presentation and should not appear twice in the text. "} That is why it is prefered
#     to use a CSS only technique for styling pullquotes.
#   {% endpullquote %}
#   ...will output...
#   <p>
#     <span data-pullquote="pullquotes are merely visual in presentation and should not appear twice in the text.">
#       When writing longform posts, I find it helpful to include pullquotes, which help those scanning a post discern whether or not a post is helpful.
#       It is important to note, pullquotes are merely visual in presentation and should not appear twice in the text. This is why a CSS only approach #       for styling pullquotes is prefered.
#     </span>
#   </p>
#
#  Strand's modification adds the ability to call this plugin with {% pullquote align:left %} which duplicates the current behavior of the pullquote plugin, with a left float and appropriate margins.

module Jekyll

  class PullquoteTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      markup =~ /align:left/i ? @align = "left" : @align = ""
      super
    end

    def render(context)
      output = super
      if output.join =~ /\{"\s*(.+)\s*"\}/
        @quote = $1
         "<span class='has-pullquote#{@align}' data-pullquote='#{@quote}'>#{output.join.gsub(/\{"\s*|\s*"\}/, '')}</span>" # TODO Determine how to makethis span have a left or right flag.
      else
        return "Surround your pullquote like this {\" text to be quoted \"}"
      end
    end
  end
end

Liquid::Template.register_tag('pullquote', Jekyll::PullquoteTag)
