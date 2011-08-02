begin require 'ripper'; rescue LoadError; end

module YARD
  module Parser
    module Ruby
      # Ruby 1.9 parser
      # @attr_reader encoding_line
      # @attr_reader shebang_line
      # @attr_reader enumerator
      class RubyParser < Parser::Base
        def initialize(source, filename)
          @parser = RipperParser.new(source, filename)
        end

        def parse; @parser.parse end
        def tokenize; @parser.tokens end
        def enumerator; @parser.enumerator end
        def shebang_line; @parser.shebang_line end
        def encoding_line; @parser.encoding_line end
      end

      # Internal parser class
      # @since 0.5.6
      class RipperParser < Ripper
        attr_reader :ast, :charno, :comments, :file, :tokens
        attr_reader :shebang_line, :encoding_line
        alias root ast

        def initialize(source, filename, *args)
          super
          @last_ns_token = nil
          @file = filename
          @source = source
          @tokens = []
          @comments = {}
          @comments_flags = {}
          @heredoc_tokens = []
          @map = {}
          @ns_charno = 0
          @list = []
          @charno = 0
          @groups = []
          @shebang_line = nil
          @encoding_line = nil
        end

        def parse
          @ast = super
          @ast.full_source = @source
          @ast.file = @file
          freeze_tree
          insert_comments
          self
        end

        def enumerator
          ast.children
        end

        private

        MAPPINGS = {
          :BEGIN => "BEGIN",
          :END => "END",
          :alias => "alias",
          :array => :lbracket,
          :arg_paren => :lparen,
          :begin => "begin",
          :blockarg => "&",
          :brace_block => :lbrace,
          :break => "break",
          :case => "case",
          :class => "class",
          :def => "def",
          :defined => "defined?",
          :defs => "def",
          :do_block => "do",
          :else => "else",
          :elsif => "elsif",
          :ensure => "ensure",
          :for => "for",
          :hash => :lbrace,
          :if => "if",
          :lambda => [:tlambda, "lambda"],
          :module => "module",
          :next => "next",
          :paren => :lparen,
          :qwords_literal => :qwords_beg,
          :redo => "redo",
          :regexp_literal => :regexp_beg,
          :rescue => "rescue",
          :rest_param => "*",
          :retry => "retry",
          :return => "return",
          :return0 => "return",
          :sclass => "class",
          :string_embexpr => :embexpr_beg,
          :string_literal => [:tstring_beg, :heredoc_beg],
          :super => "super",
          :symbol => :symbeg,
          :top_const_ref => "::",
          :undef => "undef",
          :unless => "unless",
          :until => "until",
          :when => "when",
          :while => "while",
          :xstring_literal => :backtick,
          :yield => "yield",
          :yield0 => "yield",
          :zsuper => "super"
        }
        REV_MAPPINGS = {}

        AST_TOKENS = [:CHAR, :backref, :const, :cvar, :gvar, :heredoc_end, :ident,
          :int, :float, :ivar, :label, :period, :regexp_end, :tstring_content, :backtick]

        MAPPINGS.each do |k, v|
          if Array === v
            v.each {|_v| (REV_MAPPINGS[_v] ||= []) << k }
          else
            (REV_MAPPINGS[v] ||= []) << k
          end
        end

        PARSER_EVENT_TABLE.each do |event, arity|
          node_class = AstNode.node_class_for(event)

          if /_new\z/ =~ event.to_s and arity == 0
            module_eval(<<-eof, __FILE__, __LINE__ + 1)
              def on_#{event}(*args)
                #{node_class}.new(:list, args, :listchar => charno...charno, :listline => lineno..lineno)
              end
            eof
          elsif /_add(_.+)?\z/ =~ event.to_s
            module_eval(<<-eof, __FILE__, __LINE__ + 1)
              begin; undef on_#{event}; rescue NameError; end
              def on_#{event}(list, item)
                list.push(item)
                list
              end
            eof
          elsif MAPPINGS.has_key?(event)
            module_eval(<<-eof, __FILE__, __LINE__ + 1)
              begin; undef on_#{event}; rescue NameError; end
              def on_#{event}(*args)
                visit_event #{node_class}.new(:#{event}, args)
              end
            eof
          else
            module_eval(<<-eof, __FILE__, __LINE__ + 1)
              begin; undef on_#{event}; rescue NameError; end
              def on_#{event}(*args)
                #{node_class}.new(:#{event}, args, :listline => lineno..lineno, :listchar => charno...charno)
              end
            eof
          end
        end

        SCANNER_EVENTS.each do |event|
          ast_token = AST_TOKENS.include?(event)
          module_eval(<<-eof, __FILE__, __LINE__ + 1)
            begin; undef on_#{event}; rescue NameError; end
            def on_#{event}(tok)
              visit_ns_token(:#{event}, tok, #{ast_token.inspect})
            end
          eof
        end

        REV_MAPPINGS.select {|k,v| k.is_a?(Symbol) }.each do |pair|
          event, value = *pair
          ast_token = AST_TOKENS.include?(event)
          module_eval(<<-eof, __FILE__, __LINE__ + 1)
            begin; undef on_#{event}; rescue NameError; end
            def on_#{event}(tok)
              (@map[:#{event}] ||= []) << [lineno, charno]
              visit_ns_token(:#{event}, tok, #{ast_token.inspect})
            end
          eof
        end

        [:kw, :op].each do |event|
          module_eval(<<-eof, __FILE__, __LINE__ + 1)
            begin; undef on_#{event}; rescue NameError; end
            def on_#{event}(tok)
              unless @last_ns_token == [:kw, "def"] ||
                  (@tokens.last && @tokens.last[0] == :symbeg)
                (@map[tok] ||= []) << [lineno, charno]
              end
              visit_ns_token(:#{event}, tok, true)
            end
          eof
        end

        [:sp, :nl, :ignored_nl].each do |event|
          module_eval(<<-eof, __FILE__, __LINE__ + 1)
            begin; undef on_#{event}; rescue NameError; end
            def on_#{event}(tok)
              add_token(:#{event}, tok)
              @charno += tok.length
            end
          eof
        end

        def visit_event(node)
          map = @map[MAPPINGS[node.type]]
          lstart, sstart = *(map ? map.pop : [lineno, lineno])
          node.source_range = Range.new(sstart, @ns_charno - 1)
          node.line_range = Range.new(lstart, lineno)
          node
        end

        def visit_event_arr(node)
          mapping = MAPPINGS[node.type].find {|k| @map[k] && !@map[k].empty? }
          lstart, sstart = *@map[mapping].pop
          node.source_range = Range.new(sstart, @ns_charno - 1)
          node.line_range = Range.new(lstart, lineno)
          node
        end

        def visit_ns_token(token, data, ast_token = false)
          add_token(token, data)
          ch = charno
          @last_ns_token = [token, data]
          @charno += data.length
          @ns_charno = charno
          if ast_token
            AstNode.new(token, [data], :line => lineno..lineno, :char => ch..charno-1, :token => true)
          end
        end

        def add_token(token, data)
          if @tokens.last && @tokens.last[0] == :symbeg
            @tokens[-1] = [:symbol, ":" + data]
          elsif token == :heredoc_end
            @heredoc_tokens << [@tokens.pop, [token, data]]
          else
            @tokens << [token, data]
            if token == :nl && @heredoc_tokens.size > 0
              @tokens += @heredoc_tokens.pop
            end
          end
        end

        undef on_program
        undef on_assoc_new
        undef on_hash
        undef on_bare_assoc_hash
        undef on_assoclist_from_args
        undef on_aref
        undef on_rbracket
        undef on_qwords_new
        undef on_qwords_add
        undef on_string_literal
        undef on_lambda
        undef on_string_content
        undef on_rescue
        undef on_void_stmt
        undef on_params
        undef on_label
        undef on_comment
        undef on_embdoc_beg
        undef on_embdoc
        undef on_embdoc_end
        undef on_parse_error

        def on_program(*args)
          args.first
        end

        def on_body_stmt(*args)
          args.compact.size == 1 ? args.first : AstNode.new(:list, args)
        end
        alias on_bodystmt on_body_stmt

        def on_assoc_new(*args)
          AstNode.new(:assoc, args)
        end

        def on_hash(*args)
          visit_event AstNode.new(:hash, args.first || [])
        end

        def on_bare_assoc_hash(*args)
          AstNode.new(:list, args.first)
        end

        def on_assoclist_from_args(*args)
          args.first
        end

        def on_aref(*args)
          ll, lc = *@map[:aref].pop
          sr = args.first.source_range.first..lc
          lr = args.first.line_range.first..ll
          AstNode.new(:aref, args, :char => sr, :line => lr)
        end

        def on_rbracket(tok)
          (@map[:aref] ||= []) << [lineno, charno]
          visit_ns_token(:rbracket, tok, false)
        end

        def on_top_const_ref(*args)
          type = :top_const_ref
          node = AstNode.node_class_for(type).new(type, args)
          mapping = @map[MAPPINGS[type]]
          extra_op = mapping.last[1] + 2 == charno ? mapping.pop : nil
          lstart, sstart = *mapping.pop
          node.source_range = Range.new(sstart, args.last.source_range.last)
          node.line_range = Range.new(lstart, args.last.line_range.last)
          mapping.push(extra_op) if extra_op
          node
        end

        def on_const_path_ref(*args)
          ReferenceNode.new(:const_path_ref, args, :listline => lineno..lineno, :listchar => charno..charno)
        end

        [:if_mod, :unless_mod, :while_mod].each do |kw|
          node_class = AstNode.node_class_for(kw)
          module_eval(<<-eof, __FILE__, __LINE__ + 1)
            begin; undef on_#{kw}; rescue NameError; end
            def on_#{kw}(*args)
              sr = args.last.source_range.first..args.first.source_range.last
              lr = args.last.line_range.first..args.first.line_range.last
              #{node_class}.new(:#{kw}, args, :line => lr, :char => sr)
            end
          eof
        end
        
        def on_qwords_new(*args)
          node = LiteralNode.new(:qwords_literal, args)
          if @map[:qwords_beg]
            lstart, sstart = *@map[:qwords_beg].pop
            node.source_range = Range.new(sstart, @ns_charno-1)
            node.line_range = Range.new(lstart, lineno)
          end
          node
        end
        
        def on_qwords_add(list, item)
          list.source_range = (list.source_range.first..@ns_charno-1)
          list.line_range = (list.line_range.first..lineno)
          list.push(item)
          list
        end

        def on_string_literal(*args)
          node = visit_event_arr(LiteralNode.new(:string_literal, args))
          if args.size == 1
            r = args[0].source_range
            if node.source_range != Range.new(r.first - 1, r.last + 1)
              klass = AstNode.node_class_for(node[0].type)
              r = Range.new(node.source_range.first + 1, node.source_range.last - 1)
              node[0] = klass.new(node[0].type, [@source[r]], :line => node.line_range, :char => r)
            end
          end
          node
        end

        def on_lambda(*args)
          visit_event_arr AstNode.new(:lambda, args)
        end

        def on_string_content(*args)
          AstNode.new(:string_content, args, :listline => lineno..lineno, :listchar => charno..charno)
        end

        def on_rescue(exc, *args)
          exc = AstNode.new(:list, exc) if exc
          visit_event AstNode.new(:rescue, [exc, *args])
        end

        def on_void_stmt
          AstNode.new(:void_stmt, [], :line => lineno..lineno, :char => charno...charno)
        end

        def on_params(*args)
          args.map! do |arg|
            if arg.class == Array
              if arg.first.class == Array
                arg.map! do |sub_arg|
                  if sub_arg.class == Array
                    AstNode.new(:default_arg, sub_arg, :listline => lineno..lineno, :listchar => charno..charno)
                  else
                    sub_arg
                  end
                end
              end
              AstNode.new(:list, arg, :listline => lineno..lineno, :listchar => charno..charno)
            else
              arg
            end
          end
          ParameterNode.new(:params, args, :listline => lineno..lineno, :listchar => charno..charno)
        end

        def on_label(data)
          add_token(:label, data)
          ch = charno
          @charno += data.length
          @ns_charno = charno
          AstNode.new(:label, [data[0...-1]], :line => lineno..lineno, :char => ch..charno-1, :token => true)
        end

        def on_comment(comment)
          not_comment = false
          if @last_ns_token.nil? || @last_ns_token.size == 0
            if comment =~ SourceParser::SHEBANG_LINE && !@encoding_line
              @shebang_line = comment
              not_comment = true
            elsif comment =~ SourceParser::ENCODING_LINE
              @encoding_line = comment
              not_comment = true
            end
          end

          visit_ns_token(:comment, comment)
          if not_comment
            @last_ns_token = nil
            return
          end
          case comment
          when /\A#+ @group\s+(.+)\s*\Z/
            @groups.unshift [lineno, $1]
            return
          when /\A#+ @endgroup\s*\Z/
            @groups.unshift [lineno, nil]
            return
          end

          comment = comment.gsub(/^(\#+)\s{0,1}/, '').chomp
          append_comment = @comments[lineno - 1]
          hash_flag = $1 == '##' ? true : false

          if append_comment && @comments_last_column == column
            @comments.delete(lineno - 1)
            @comments_flags[lineno] = @comments_flags[lineno - 1]
            @comments_flags.delete(lineno - 1)
            comment = append_comment + "\n" + comment
          end

          @comments[lineno] = comment
          @comments_flags[lineno] = hash_flag if !append_comment
          @comments_last_column = column
        end

        def on_embdoc_beg(text)
          visit_ns_token(:embdoc_beg, text)
          @embdoc = ""
        end

        def on_embdoc(text)
          visit_ns_token(:embdoc, text)
          @embdoc << text
        end

        def on_embdoc_end(text)
          visit_ns_token(:embdoc_end, text)
          @comments[lineno] = @embdoc
          @embdoc = nil
        end

        def on_parse_error(msg)
          raise ParserSyntaxError, "syntax error in `#{file}`:(#{lineno},#{column}): #{msg}"
        end

        def insert_comments
          root.traverse do |node|
            next if node.type == :list || node.parent.type != :list
            (node.line - 2).upto(node.line) do |line|
              comment = @comments[line]
              if comment && !comment.empty?
                node.docstring_hash_flag = @comments_flags[line]
                node.docstring = comment
                node.docstring_range = ((line - comment.count("\n"))..line)
                @comments.delete(line)
                @comments_flags.delete(line)
                break
              end
            end
            if node.type == :def || node.type == :defs || node.call?
              @groups.each do |group|
                if group.first < node.line
                  break node.group = group.last
                end
              end
            end
          end
        end

        def freeze_tree(node = nil)
          node ||= root
          node.children.each do |child|
            child.parent = node
            freeze_tree(child)
          end
        end
      end if defined?(::Ripper)
    end
  end
end