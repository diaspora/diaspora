require 'pathname'

module Jekyll

  class IncludeCodeTag < Liquid::Tag
    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    def render(context)
      code_dir = (context.registers[:site].config['code_dir'] || 'downloads/code')
      code_path = (Pathname.new(context.registers[:site].source) + code_dir).expand_path
      file = code_path + @file

      if File.symlink?(code_path)
        return "Code directory '#{code_path}' cannot be a symlink"
      end

      unless file.file?
        return "File #{file} could not be found"
      end

      Dir.chdir(code_path) do
        code = file.read
        file_type = file.extname
        url = "#{context.registers[:site].config['url']}/#{code_dir}/#{@file}"
        source = "<figure><figcaption><span>#{file.basename}</span> <a href='#{url}'>download</a></figcaption>\n"
        source += "{% highlight #{file_type} %}\n" + code + "\n{% endhighlight %}</figure>"
        partial = Liquid::Template.parse(source)
        context.stack do
          partial.render(context)
        end
      end
    end
  end

end

Liquid::Template.register_tag('include_code', Jekyll::IncludeCodeTag)
