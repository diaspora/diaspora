module YARD
  module Server
    module Commands
      # Displays documentation for a specific object identified by the path
      class DisplayObjectCommand < LibraryCommand
        def run
          return index if path.empty?

          if object = Registry.at(object_path)
            options.update(:type => :layout)
            render(object)
          else
            self.status = 404
          end
        end

        def index
          Registry.load_all

          title = options[:title]
          unless title
            title = "Documentation for #{library.name} #{library.version ? '(' + library.version + ')' : ''}"
          end
          options.update(
            :object => '_index.html',
            :objects => Registry.all(:module, :class),
            :title => title,
            :type => :layout
          )
          render
        end

        def not_found
          super
          self.body = "Could not find object: #{object_path}"
        end

        private

        def object_path
          return @object_path if @object_path
          if path == "toplevel"
            @object_path = :root
          else
            @object_path = path.sub(':', '#').gsub('/', '::').sub(/^toplevel\b/, '').sub(/\.html$/, '')
          end
        end
      end
    end
  end
end
