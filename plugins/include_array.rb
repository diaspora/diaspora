# Title: Include Array Tag for Jekyll
# Author: Jason Woodward http://www.woodwardjd.com
# Description: Import files on your filesystem as specified in a configuration variable in _config.yml.  Mostly cribbed from Jekyll's include tag.
# Syntax: {% include_array variable_name_from_config.yml %}
#
# Example 1:
# {% include_array asides  %}
#
# _config.yml snippet:
# asides: [asides/twitter.html, asides/custom/my_picture.html]
#
module Jekyll

  class IncludeArrayTag < Liquid::Tag
    Syntax = /(#{Liquid::QuotedFragment}+)/
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @array_name = $1
      else
        raise SyntaxError.new("Error in tag 'include_array' - Valid syntax: include_array [array from _config.yml]")
      end

      super
    end

    def render(context)
      includes_dir = File.join(context.registers[:site].source, '_includes')

      if File.symlink?(includes_dir)
        return "Includes directory '#{includes_dir}' cannot be a symlink"
      end

      rtn = ''
      (context.environments.first['site'][@array_name] || []).each do |file|
        if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
          rtn = rtn + "Include file '#{file}' contains invalid characters or sequences"
        end

        Dir.chdir(includes_dir) do
          choices = Dir['**/*'].reject { |x| File.symlink?(x) }
          if choices.include?(file)
            source = File.read(file)
            partial = Liquid::Template.parse(source)
            context.stack do
              rtn = rtn + partial.render(context)
            end
          else
            rtn = rtn + "Included file '#{file}' not found in _includes directory"
          end
        end
      end
      rtn
    end
  end

end

Liquid::Template.register_tag('include_array', Jekyll::IncludeArrayTag)
