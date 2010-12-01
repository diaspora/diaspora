require 'thor/actions/empty_directory'

class Thor
  module Actions

    # Copies recursively the files from source directory to root directory.
    # If any of the files finishes with .tt, it's considered to be a template
    # and is placed in the destination without the extension .tt. If any
    # empty directory is found, it's copied and all .empty_directory files are
    # ignored. Remember that file paths can also be encoded, let's suppose a doc
    # directory with the following files:
    #
    #   doc/
    #     components/.empty_directory
    #     README
    #     rdoc.rb.tt
    #     %app_name%.rb
    #
    # When invoked as:
    #
    #   directory "doc"
    #
    # It will create a doc directory in the destination with the following
    # files (assuming that the `app_name` method returns the value "blog"):
    #
    #   doc/
    #     components/
    #     README
    #     rdoc.rb
    #     blog.rb
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #                If :recursive => false, does not look for paths recursively.
    #
    # ==== Examples
    #
    #   directory "doc"
    #   directory "doc", "docs", :recursive => false
    #
    def directory(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      action Directory.new(self, source, destination || source, config, &block)
    end

    class Directory < EmptyDirectory #:nodoc:
      attr_reader :source

      def initialize(base, source, destination=nil, config={}, &block)
        @source = File.expand_path(base.find_in_source_paths(source.to_s))
        @block  = block
        super(base, destination, { :recursive => true }.merge(config))
      end

      def invoke!
        base.empty_directory given_destination, config
        execute!
      end

      def revoke!
        execute!
      end

      protected

        def execute!
          lookup = config[:recursive] ? File.join(source, '**') : source
          lookup = File.join(lookup, '{*,.[a-z]*}')

          Dir[lookup].sort.each do |file_source|
            next if File.directory?(file_source)
            file_destination = File.join(given_destination, file_source.gsub(source, '.'))
            file_destination.gsub!('/./', '/')

            case file_source
              when /\.empty_directory$/
                dirname = File.dirname(file_destination).gsub(/\/\.$/, '')
                next if dirname == given_destination
                base.empty_directory(dirname, config)
              when /\.tt$/
                destination = base.template(file_source, file_destination[0..-4], config, &@block)
              else
                destination = base.copy_file(file_source, file_destination, config, &@block)
            end
          end
        end

    end
  end
end
