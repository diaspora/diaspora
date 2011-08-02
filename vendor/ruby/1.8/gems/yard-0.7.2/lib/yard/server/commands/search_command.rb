module YARD
  module Server
    module Commands
      # Performs a search over the objects inside of a library and returns
      # the results as HTML or plaintext
      class SearchCommand < LibraryCommand
        attr_accessor :results, :query

        def run
          Registry.load_all
          self.query = request.query['q']
          redirect("/#{adapter.router.docs_prefix}/#{single_library ? library : ''}") if query.nil? || query =~ /\A\s*\Z/
          if found = Registry.at(query)
            redirect(serializer.serialized_path(found))
          end
          search_for_object
          request.xhr? ? serve_xhr : serve_normal
        end

        def visible_results
          results[0, 10]
        end

        private

        def serve_xhr
          self.headers['Content-Type'] = 'text/plain'
          self.body = visible_results.map {|o|
            [(o.type == :method ? o.name(true) : o.name).to_s,
             o.path,
             o.namespace.root? ? '' : o.namespace.path,
             serializer.serialized_path(o)
            ].join(",")
          }.join("\n")
        end

        def serve_normal
          options.update(
            :visible_results => visible_results,
            :query => query,
            :results => results,
            :template => :doc_server,
            :type => :search
          )
          self.body = Templates::Engine.render(options)
        end

        def search_for_object
          splitquery = query.split(/\s+/).map {|c| c.downcase }.reject {|m| m.empty? }
          self.results = Registry.all.select {|o|
              o.path.downcase.include?(query.downcase)
            }.reject {|o|
              name = (o.type == :method ? o.name(true) : o.name).to_s.downcase
              !name.include?(query.downcase) ||
              case o.type
              when :method
                !(query =~ /[#.]/) && query.include?("::")
              when :class, :module, :constant, :class_variable
                query =~ /[#.]/
              end
            }.sort_by {|o|
              name = (o.type == :method ? o.name(true) : o.name).to_s
              name.length.to_f / query.length.to_f
            }
        end
      end
    end
  end
end
