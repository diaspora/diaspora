module YARD
  module Server
    module Commands
      # Displays an object wrapped in frames
      class FramesCommand < DisplayObjectCommand
        include DocServerHelper

        def run
          main_url = request.path.gsub(/^(.+)?\/frames(?:\/(#{path}))?$/, '\1/\2')
          if path =~ %r{^file/}
            page_title = "File: #{$'}"
          elsif !path.empty?
            page_title = "Object: #{object_path}"
          elsif options[:files] && options[:files].size > 0
            page_title = "File: #{File.basename(options[:files].first.path)}"
            main_url = url_for_file(options[:files].first)
          elsif !path || path.empty?
            page_title = "Documentation for #{library.name} #{library.version ? '(' + library.version + ')' : ''}"
          end

          options.update(
            :page_title => page_title,
            :main_url => main_url,
            :template => :doc_server,
            :type => :frames
          )
          render
        end
      end
    end
  end
end
