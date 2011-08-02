# Parts of this source were borrowed from `rdoc/parser/c.rb`
# RDoc's license is packaged along with Ruby.


module YARD
  module Parser
    class CParser < Base
      def initialize(source, file = '(stdin)')
        @file = file
        @namespaces = {}
        @content = clean_source(source)
      end

      def parse
        parse_modules
        parse_classes
        parse_methods
        parse_constants
        parse_includes
      end

      # @since 0.5.6
      def tokenize
        raise NotImplementedError, "no tokenization support for C/C++ files"
      end

      private

      # @since 0.5.3
      def remove_var_prefix(var)
        var.gsub(/^rb_[mc]|^[a-z_]+/, '')
      end

      def ensure_loaded!(object, max_retries = 1)
        return if object.is_a?(CodeObjects::RootObject)
        unless CONTINUATIONS_SUPPORTED
          log.warn_no_continuations
          raise Handlers::NamespaceMissingError, object
        end

        retries = 0
        context = callcc {|c| c }
        retries += 1

        if object.is_a?(CodeObjects::Proxy)
          if retries <= max_retries
            log.debug "Missing object #{object} in file `#{@file}', moving it to the back of the line."
            raise Parser::LoadOrderError, context
          end
        end
        object
      end

      def handle_module(var_name, mod_name, in_module = nil)
        namespace = @namespaces[in_module] || (in_module ? P(remove_var_prefix(in_module)) : :root)
        ensure_loaded!(namespace)
        obj = CodeObjects::ModuleObject.new(namespace, mod_name)
        obj.add_file(@file)
        find_namespace_docstring(obj)
        @namespaces[var_name] = obj
      end

      def handle_class(var_name, class_name, parent, in_module = nil)
        parent = nil if parent == "0"
        namespace = @namespaces[in_module] || (in_module ? P(remove_var_prefix(in_module)) : :root)
        ensure_loaded!(namespace)
        obj = CodeObjects::ClassObject.new(namespace, class_name)
        obj.superclass = @namespaces[parent] || remove_var_prefix(parent) if parent
        obj.add_file(@file)
        find_namespace_docstring(obj)
        @namespaces[var_name] = obj
      end

      def handle_method(scope, var_name, name, func_name, source_file = nil)
        case scope
        when "singleton_method", "module_function"; scope = :class
        else; scope = :instance
        end

        namespace = @namespaces[var_name] || P(remove_var_prefix(var_name))
        ensure_loaded!(namespace)
        obj = CodeObjects::MethodObject.new(namespace, name, scope)
        obj.add_file(@file)
        obj.parameters = []
        obj.docstring.add_tag(YARD::Tags::Tag.new(:return, '', 'Boolean')) if name =~ /\?$/
        obj.source_type = :c

        content = nil
        begin
          content = File.read(source_file) if source_file
        rescue Errno::ENOENT
          path = "#{namespace}#{scope == :instance ? '#' : '.'}#{name}"
          log.warn "Missing source file `#{source_file}' when parsing #{path}"
        ensure
          content ||= @content
        end
        find_method_body(obj, func_name, content)
      end

      def handle_constants(type, var_name, const_name, definition)
        namespace = @namespaces[var_name]
        obj = CodeObjects::ConstantObject.new(namespace, const_name)
        obj.value = definition
        obj.add_file(@file)
        obj.source_type = :c
        comment = find_constant_docstring(obj, type, const_name)

        # In the case of rb_define_const, the definition and comment are in
        # "/* definition: comment */" form.  The literal ':' and '\' characters
        # can be escaped with a backslash.
        if type.downcase == 'const'
          elements = comment.split(':')
          new_definition = elements[0..-2].join(':')
          if new_definition.empty? then # Default to literal C definition
            new_definition = definition
          else
            new_definition.gsub!("\:", ":")
            new_definition.gsub!("\\", '\\')
          end
          new_definition.sub!(/\A(\s+)/, '')
          comment = $1.nil? ? elements.last : "#{$1}#{elements.last.lstrip}"
        end

        obj.docstring = comment
      end

      def find_namespace_docstring(object)
        comment = nil
        if @content =~ %r{((?>/\*.*?\*/\s+))
                       (static\s+)?void\s+Init_#{object.name}\s*(?:_\(\s*)?\(\s*(?:void\s*)\)}xmi then
          comment = $1
        elsif @content =~ %r{Document-(?:class|module):\s#{object.path}\s*?(?:<\s+[:,\w]+)?\n((?>.*?\*/))}m
          comment = $1
        end
        object.docstring = parse_comments(object, comment) if comment
      end

      def find_constant_docstring(object, type, const_name)
        comment = if @content =~ %r{((?>^\s*/\*.*?\*/\s+))
                       rb_define_#{type}\((?:\s*(\w+),)?\s*"#{const_name}"\s*,.*?\)\s*;}xmi
          $1
        elsif @content =~ %r{Document-(?:const|global|variable):\s#{const_name}\s*?\n((?>.*?\*/))}m
          $1
        else
          ''
        end
        object.docstring = parse_comments(object, comment) if comment
      end

      def find_method_body(object, func_name, content = @content)
        case content
        when %r"((?>/\*.*?\*/\s*))(?:(?:static|SWIGINTERN)\s+)?(?:intern\s+)?VALUE\s+#{func_name}
                \s*(\([^)]*\))([^;]|$)"xm
          comment, params = $1, $2
          body_text = $&

          remove_private_comments(comment) if comment

          # see if we can find the whole body

          re = Regexp.escape(body_text) + '[^(]*\{.*?\}'
          body_text = $& if /#{re}/m =~ content

          # The comment block may have been overridden with a 'Document-method'
          # block. This happens in the interpreter when multiple methods are
          # vectored through to the same C method but those methods are logically
          # distinct (for example Kernel.hash and Kernel.object_id share the same
          # implementation

          override_comment = find_override_comment(object)
          comment = override_comment if override_comment

          object.docstring = parse_comments(object, comment) if comment
          object.source = body_text.gsub(/\A#{Regexp.quote comment}/, '')
        when %r{((?>/\*.*?\*/\s*))^\s*\#\s*define\s+#{func_name}\s+(\w+)}m
          comment = $1
          find_method_body(object, $2, content)
        else
          # No body, but might still have an override comment
          comment = find_override_comment(object)
          object.docstring = parse_comments(object, comment) if comment
        end
      end

      def find_override_comment(object, content = @content)
        name = Regexp.escape(object.name.to_s)
        class_name = object.parent.path
        if content =~ %r{Document-method:\s+#{class_name}(?:\.|::|#)#{name}\s*?\n((?>.*?\*/))}m then
          $1
        elsif content =~ %r{Document-method:\s#{name}\s*?\n((?>.*?\*/))}m then
          $1
        else
          nil
        end
      end

      def parse_comments(object, comments)
        spaces = nil
        comments = remove_private_comments(comments)
        comments = comments.split(/\r?\n/).map do |line|
          line.gsub!(/^\s*\/?\*\/?/, '')
          line.gsub!(/\*\/\s*$/, '')
          if line =~ /^\s*$/
            next if spaces.nil?
            next ""
          end
          spaces = (line[/^(\s+)/, 1] || "").size if spaces.nil?
          line.gsub(/^\s{0,#{spaces}}/, '').rstrip
        end.compact

        comments.shift if comments.first =~ /^\s*Document-method:/
        comments = parse_callseq(object, comments)
        comments.join("\n")
      end

      def parse_callseq(object, comments)
        return comments unless comments[0] =~ /\Acall-seq:\s*(\S.+)?/
        if $1
          comments[0] = " #{$1}"
        else
          comments.shift
        end
        overloads = []
        seen_data = false
        while comments.first =~ /^\s+(\S.+)/ || comments.first =~ /^\s*$/
          line = comments.shift.strip
          break if line.empty? && seen_data
          next if line.empty?
          seen_data = true
          line.sub!(/^\w+[\.#]/, '')
          signature, types = *line.split(/ [-=]> /)
          types = parse_types(object, types)
          if signature.sub!(/\[?\s*(\{(?:\s*\|(.+?)\|)?.*\})\s*\]?\s*$/, '') && $1
            blk, blkparams = $1, $2
          else
            blk, blkparams = nil, nil
          end
          case signature
          when /^(\w+)\s*=\s+(\w+)/
            signature = "#{$1}=(#{$2})"
          when /^\w+\s+\S/
            signature = signature.split(/\s+/)
            signature = "#{signature[1]}#{signature[2] ? '(' + signature[2..-1].join(' ') + ')' : ''}"
          when /^\w+\[(.+?)\]\s*(=)?/
            signature = "[]#{$2}(#{$1})"
          when /^\w+\s+(#{CodeObjects::METHODMATCH})\s+(\w+)/
            signature = "#{$1}(#{$2})"
          end
          break unless signature =~ /^#{CodeObjects::METHODNAMEMATCH}/
          signature = signature.rstrip
          overloads << "@overload #{signature}"
          overloads << "  @yield [#{blkparams}]" if blk
          overloads << "  @return [#{types.join(', ')}]" unless types.empty?
        end

        comments + [""] + overloads
      end

      def parse_types(object, types)
        if types =~ /true or false/
          ["Boolean"]
        else
          (types||"").split(/,| or /).map do |t|
            case t.strip.gsub(/^an?_/, '')
            when "class"; "Class"
            when "obj", "object", "anObject"; "Object"
            when "arr", "array", "anArray", /^\[/; "Array"
            when "str", "string", "new_str"; "String"
            when "enum", "anEnumerator"; "Enumerator"
            when "exc", "exception"; "Exception"
            when "proc", "proc_obj", "prc"; "Proc"
            when "binding"; "Binding"
            when "hsh", "hash", "aHash"; "Hash"
            when "ios", "io"; "IO"
            when "file"; "File"
            when "float"; "Float"
            when "time", "new_time"; "Time"
            when "dir", "aDir"; "Dir"
            when "regexp", "new_regexp"; "Regexp"
            when "matchdata"; "MatchData"
            when "encoding"; "Encoding"
            when "fixnum", "fix"; "Fixnum"
            when "int", "integer", "Integer"; "Integer"
            when "num", "numeric", "Numeric", "number"; "Numeric"
            when "aBignum"; "Bignum"
            when "nil"; "nil"
            when "true"; "true"
            when "false"; "false"
            when "boolean", "Boolean"; "Boolean"
            when "self"; object.namespace.name.to_s
            when /^[-+]?\d/; t
            end
          end.compact
        end
      end

      def parse_modules
        @content.scan(/(\w+)\s* = \s*rb_define_module\s*
            \(\s*"(\w+)"\s*\)/mx) do |var_name, class_name|
          handle_module(var_name, class_name)
        end

        @content.scan(/(\w+)\s* = \s*rb_define_module_under\s*
                  \(
                     \s*(\w+),
                     \s*"(\w+)"
                  \s*\)/mx) do |var_name, in_module, class_name|
          handle_module(var_name, class_name, in_module)
        end
      end

      def parse_classes
        # The '.' lets us handle SWIG-generated files
        @content.scan(/([\w\.]+)\s* = \s*(?:rb_define_class|boot_defclass)\s*
                  \(
                     \s*"(\w+)",
                     \s*(\w+|0)\s*
                  \)/mx) do |var_name, class_name, parent|
          handle_class(var_name, class_name, parent)
        end

        @content.scan(/([\w\.]+)\s* = \s*rb_define_class_under\s*
                  \(
                     \s*(\w+),
                     \s*"(\w+)",
                     \s*([\w\*\s\(\)\.\->]+)\s*  # for SWIG
                  \s*\)/mx) do |var_name, in_module, class_name, parent|
          handle_class(var_name, class_name, parent, in_module)
        end
      end

      def parse_methods
        @content.scan(%r{rb_define_
                       (
                          singleton_method |
                          method           |
                          module_function  |
                          private_method
                       )
                       \s*\(\s*([\w\.]+),
                         \s*"([^"]+)",
                         \s*(?:RUBY_METHOD_FUNC\(|VALUEFUNC\()?(\w+)\)?,
                         \s*(-?\w+)\s*\)
                       (?:;\s*/[*/]\s+in\s+(\w+?\.[cy]))?
                     }xm) do |type, var_name, name, func_name, param_count, source_file|

          # Ignore top-object and weird struct.c dynamic stuff
          next if var_name == "ruby_top_self"
          next if var_name == "nstr"
          next if var_name == "envtbl"

          var_name = "rb_cObject" if var_name == "rb_mKernel"
          handle_method(type, var_name, name, func_name, source_file)
        end

        @content.scan(%r{rb_define_global_function\s*\(
                                 \s*"([^"]+)",
                                 \s*(?:RUBY_METHOD_FUNC\(|VALUEFUNC\()?(\w+)\)?,
                                 \s*(-?\w+)\s*\)
                    (?:;\s*/[*/]\s+in\s+(\w+?\.[cy]))?
                    }xm) do |name, func_name, param_count, source_file|
          handle_method("method", "rb_mKernel", name, func_name, source_file)
        end
      end

      def parse_includes
        @content.scan(/rb_include_module\s*\(\s*(\w+?),\s*(\w+?)\s*\)/) do |klass, mod|
          if klass = @namespaces[klass]
            mod = @namespaces[mod] || P(remove_var_prefix(mod))
            klass.mixins(:instance) << mod
          end
        end
      end

      def parse_constants
        @content.scan(%r{\Wrb_define_
                       (
                          variable |
                          readonly_variable |
                          const |
                          global_const |
                        )
                   \s*\(
                     (?:\s*(\w+),)?
                     \s*"(\w+)",
                     \s*(.*?)\s*\)\s*;
                     }xm) do |type, var_name, const_name, definition|
          var_name = "rb_cObject" if !var_name or var_name == "rb_mKernel"
          handle_constants(type, var_name, const_name, definition)
        end
      end

      private

      def clean_source(source)
        source = handle_ifdefs_in(source)
        source = handle_tab_width(source)
        source = remove_commented_out_lines(source)
        source
      end

      def handle_ifdefs_in(body)
        body.gsub(/^#ifdef HAVE_PROTOTYPES.*?#else.*?\n(.*?)#endif.*?\n/m, '\1')
      end

      def handle_tab_width(body)
        if /\t/ =~ body
          tab_width = 4
          body.split(/\n/).map do |line|
            1 while line.gsub!(/\t+/) { ' ' * (tab_width*$&.length - $`.length % tab_width)}  && $~ #`
            line
          end .join("\n")
        else
          body
        end
      end

      def remove_commented_out_lines(body)
        body.gsub(%r{//.*rb_define_}, '//')
      end

      def remove_private_comments(comment)
         comment = comment.gsub(/\/?\*--\n(.*?)\/?\*\+\+/m, '')
         comment = comment.sub(/\/?\*--\n.*/m, '')
         comment
      end
    end
  end
end
