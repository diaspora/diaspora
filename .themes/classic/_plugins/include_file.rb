require 'pathname'

module Jekyll

  class IncludePartialTag < Liquid::Tag
    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    def render(context)
      file_dir = (context.registers[:site].source || 'source')
      file_path = Pathname.new(file_dir).expand_path
      file = file_path + @file

      unless file.file?
        return "File #{file} could not be found"
      end

      Dir.chdir(file_path) do
        partial = Liquid::Template.parse(file.read)
        context.stack do
          partial.render(context)
        end
      end
    end
  end
end

Liquid::Template.register_tag('include_partial', Jekyll::IncludePartialTag)

