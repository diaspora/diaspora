require 'erb'

module YARD
  module Templates
    module Template
      attr_accessor :class, :section
      attr_reader :options

      class << self
        # @return [Array<Module>] a list of modules to be automatically included
        #   into any new template module
        attr_accessor :extra_includes

        # @private
        def included(klass)
          klass.extend(ClassMethods)
        end
      end

      self.extra_includes = []

      include ErbCache
      include Helpers::BaseHelper
      include Helpers::MethodHelper

      module ClassMethods
        attr_accessor :path, :full_path

        def full_paths
          included_modules.inject([full_path]) do |paths, mod|
            paths |= mod.full_paths if mod.respond_to?(:full_paths)
            paths
          end
        end

        def initialize(path, full_paths)
          full_path = full_paths.shift
          self.path = path
          self.full_path = full_path
          include_inherited(full_paths)
          include_parent
          load_setup_rb
        end

        # Searches for a file identified by +basename+ in the template's
        # path as well as any mixed in template paths. Equivalent to calling
        # {ClassMethods#find_nth_file} with index of 1.
        #
        # @param [String] basename the filename to search for
        # @return [String] the full path of a file on disk with filename
        #   +basename+ in one of the template's paths.
        # @see find_nth_file
        def find_file(basename)
          find_nth_file(basename)
        end

        # Searches for the nth file (where n = +index+) identified
        # by basename in the template's path and any mixed in template paths.
        #
        # @param [String] basename the filename to search for
        # @param [Fixnum] index the nth existing file to return
        # @return [String] the full path of the nth file on disk with
        #   filename +basename+ in one of the template paths
        def find_nth_file(basename, index = 1)
          n = 1
          full_paths.each do |path|
            file = File.join(path, basename)
            if File.file?(file)
              return file if index == n
              n += 1
            end
          end

          nil
        end

        def is_a?(klass)
          return true if klass == Template
          super(klass)
        end

        # Creates a new template object to be rendered with {Template#run}
        def new(*args)
          obj = Object.new.extend(self)
          obj.class = self
          obj.send(:initialize, *args)
          obj
        end

        def run(*args)
          new(*args).run
        end

        def T(*path)
          Engine.template(*path)
        end

        # Alias for creating a {Section} with arguments
        # @see Section#initialize
        # @since 0.6.0
        def S(*args)
          Section.new(*args)
        end

        private

        def include_parent
          pc = path.to_s.split('/')
          if pc.size > 1
            pc.pop
            pc = pc.join('/')
            begin
              include Engine.template(pc)
            rescue ArgumentError
              include Engine.template!(pc, full_path.gsub(%r{/[^/]+$}, ''))
            end
          end
        end

        def include_inherited(full_paths)
          full_paths.reverse.each do |full_path|
            include Engine.template!(path, full_path)
          end
        end

        def load_setup_rb
          setup_file = File.join(full_path, 'setup.rb')
          if File.file? setup_file
            module_eval(File.read(setup_file).taint, setup_file, 1)
          end
        end
      end

      def initialize(opts = {})
        @cache, @cache_filename = {}, {}
        @sections, @options = [], {}
        add_options(opts)

        extend(Helpers::HtmlHelper) if options[:format] == :html
        extend(Helpers::TextHelper) if options[:format] == :text
        extend(Helpers::UMLHelper) if options[:format] == :dot
        extend(*Template.extra_includes) unless Template.extra_includes.empty?

        init
      end

      # Loads a template specified by path. If +:template+ or +:format+ is
      # specified in the {#options} hash, they are prepended and appended
      # to the path respectively.
      #
      # @param [Array<String, Symbol>] path the path of the template
      # @return [Template] the loaded template module
      def T(*path)
        path.unshift(options[:template]) if options[:template]
        path.push(options[:format]) if options[:format]
        self.class.T(*path)
      end

      # Sets the sections (and subsections) to be rendered for the template
      #
      # @example Sets a set of erb sections
      #   sections :a, :b, :c # searches for a.erb, b.erb, c.erb
      # @example Sets a set of method and erb sections
      #   sections :a, :b, :c # a is a method, the rest are erb files
      # @example Sections with subsections
      #   sections :header, [:name, :children]
      #   # the above will call header.erb and only renders the subsections
      #   # if they are yielded by the template (see #yieldall)
      # @param [Array<Symbol, String, Template, Array>] args the sections
      #   to use to render the template. For symbols and strings, the
      #   section will be executed as a method (if one exists), or rendered
      #   from the file "name.erb" where name is the section name. For
      #   templates, they will have {Template::ClassMethods#run} called on them.
      #   Any subsections can be yielded to using yield or {#yieldall}
      def sections(*args)
        @sections = Section.new(nil, *args) if args.size > 0
        @sections
      end

      # Initialization called on the template. Override this in a 'setup.rb'
      # file in the template's path to implement a template
      #
      # @example A default set of sections
      #   def init
      #     sections :section1, :section2, [:subsection1, :etc]
      #   end
      # @see #sections
      def init
      end

      # Runs a template on +sects+ using extra options. This method should
      # not be called directly. Instead, call the class method {ClassMethods#run}
      #
      # @param [Hash, nil] opts any extra options to apply to sections
      # @param [Section, Array] sects a section list of sections to render
      # @param [Fixnum] start_at the index in the section list to start from
      # @param [Boolean] break_first if true, renders only the first section
      # @yield [opts] calls for the subsections to be rendered
      # @yieldparam [Hash] opts any extra options to yield
      # @return [String] the rendered sections joined together
      def run(opts = nil, sects = sections, start_at = 0, break_first = false, &block)
        out = ""
        return out if sects.nil?
        sects = sects[start_at..-1] if start_at > 0
        sects = Section.new(nil, sects) unless sects.is_a?(Section)
        add_options(opts) do
          sects.each do |s|
            self.section = s
            subsection_index = 0
            value = render_section(section) do |*args|
              value = with_section do
                run(args.first, section, subsection_index, true, &block)
              end
              subsection_index += 1
              value
            end
            out << (value || "")
            break if break_first
          end
        end
        out
      end

      # Yields all subsections with any extra options
      #
      # @param [Hash] opts extra options to be applied to subsections
      def yieldall(opts = nil, &block)
        with_section { run(opts, section, &block) }
      end

      # @param [String, Symbol] section the section name
      # @yield calls subsections to be rendered
      # @return [String] the contents of the ERB rendered section
      def erb(section, &block)
        method_name = ErbCache.method_for(cache_filename(section)) do
          erb_with(cache(section), cache_filename(section))
        end
        send(method_name, &block)
      end

      # Returns the contents of a file. If +allow_inherited+ is set to +true+,
      # use +{{{__super__}}}+ inside the file contents to insert the contents
      # of the file from an inherited template. For instance, if +templates/b+
      # inherits from +templates/a+ and file "test.css" exists in both directories,
      # both file contents can be retrieved by having +templates/b/test.css+ look
      # like:
      #
      #   {{{__super__}}}
      #   ...
      #   body { css styles here }
      #   p.class { other styles }
      #
      # @param [String] basename the name of the file
      # @param [Boolean] allow_inherited whether inherited templates can
      #   be inserted with +{{{__super__}}}+
      # @return [String] the contents of a file identified by +basename+. All
      #   template paths (including any mixed in templates) are searched for
      #   the file
      # @see ClassMethods#find_file
      # @see ClassMethods#find_nth_file
      def file(basename, allow_inherited = false)
        file = self.class.find_file(basename)
        raise ArgumentError, "no file for '#{basename}' in #{self.class.path}" unless file

        data = IO.read(file)
        if allow_inherited
          superfile = self.class.find_nth_file(basename, 2)
          data.gsub!('{{{__super__}}}', superfile ? IO.read(superfile) : "")
        end

        data
      end

      # Calls the ERB file from the last inherited template with {#section}.erb
      #
      # @param [Symbol, String] section if provided, uses a specific section name
      # @return [String] the rendered ERB file in any of the inherited template
      #   paths.
      def superb(section = section, &block)
        filename = self.class.find_nth_file(erb_file_for(section), 2)
        return "" unless filename
        method_name = ErbCache.method_for(filename) { erb_with(IO.read(filename), filename) }
        send(method_name, &block)
      end

      def options=(value)
        @options = value
        set_ivars
      end

      def inspect
        "Template(#{self.class.path}) [section=#{section.name}]"
      end

      protected

      def erb_file_for(section)
        "#{section}.erb"
      end

      def erb_with(content, filename = nil)
        erb = ERB.new(content, nil, options[:format] == :text ? '<>' : nil)
        erb.filename = filename if filename
        erb
      end

      private

      def render_section(section, &block)
        section = section.name if section.is_a?(Section)
        case section
        when Section, String, Symbol
          if respond_to?(section)
            send(section, &block)
          else
            erb(section, &block)
          end
        when Module, Template
          section.run(options, &block) if section.is_a?(Template)
        end || ""
      end

      def cache(section)
        content = @cache[section.to_sym]
        return content if content

        file = cache_filename(section)
        @cache_filename[section.to_sym] = file
        raise ArgumentError, "no template for section '#{section}' in #{self.class.path}" unless file
        @cache[section.to_sym] = IO.read(file)
      end

      def cache_filename(section)
        @cache_filename[section.to_sym] ||=
          self.class.find_file(erb_file_for(section))
      end

      def set_ivars
        options.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end

      def add_options(opts = nil)
        return(yield) if opts.nil? && block_given?
        cur_opts = options if block_given?

        self.options = options.merge(opts)

        if block_given?
          value = yield
          self.options = cur_opts
          value
        end
      end

      def with_section(&block)
        sect = section
        value = yield
        self.section = sect
        value
      end
    end
  end
end

