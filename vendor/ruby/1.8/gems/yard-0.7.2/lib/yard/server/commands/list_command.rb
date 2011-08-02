module YARD
  module Server
    module Commands
      # Returns a list of objects of a specific type
      class ListCommand < LibraryCommand
        include Templates::Helpers::BaseHelper

        def items; raise NotImplementedError end
        def type; raise NotImplementedError end

        def run
          options.update(:items => items, :template => :doc_server,
                         :list_type => request.path.split('/').last, :type => :full_list)
          render
        end
      end

      # Returns the list of classes / modules in a library
      class ListClassesCommand < ListCommand
        def type; :class end

        def items
          Registry.load_all
          run_verifier(Registry.all(:class, :module))
        end
      end

      # Returns the list of methods in a library
      class ListMethodsCommand < ListCommand
        include Templates::Helpers::ModuleHelper

        def type; :methods end

        def items
          Registry.load_all
          items = Registry.all(:method).sort_by {|m| m.name.to_s }
          prune_method_listing(items)
        end
      end

      # Returns the list of README/extra files in a library
      class ListFilesCommand < ListCommand
        def type; :files end
        def items; options[:files] end
      end
    end
  end
end
