require 'cgi'

module Haml
  module Compiler
    include Haml::Util

    private

    # Returns the precompiled string with the preamble and postamble
    def precompiled_with_ambles(local_names)
      preamble = <<END.gsub("\n", ";")
begin
extend Haml::Helpers
_hamlout = @haml_buffer = Haml::Buffer.new(@haml_buffer, #{options_for_buffer.inspect})
_erbout = _hamlout.buffer
__in_erb_template = true
END
      postamble = <<END.gsub("\n", ";")
#{precompiled_method_return_value}
ensure
@haml_buffer = @haml_buffer.upper
end
END
      preamble + locals_code(local_names) + precompiled + postamble
    end

    # Returns the string used as the return value of the precompiled method.
    # This method exists so it can be monkeypatched to return modified values.
    def precompiled_method_return_value
      "_erbout"
    end

    def locals_code(names)
      names = names.keys if Hash == names

      names.map do |name|
        # Can't use || because someone might explicitly pass in false with a symbol
        sym_local = "_haml_locals[#{inspect_obj(name.to_sym)}]"
        str_local = "_haml_locals[#{inspect_obj(name.to_s)}]"
        "#{name} = #{sym_local}.nil? ? #{str_local} : #{sym_local}"
      end.join(';') + ';'
    end

    def compile_root
      @dont_indent_next_line = @dont_tab_up_next_text = false
      @output_line = 1
      @indentation = nil
      yield
      flush_merged_text
    end

    def compile_plain
      push_text @node.value[:text]
    end

    def compile_script(&block)
      push_script(@node.value[:text],
        :preserve_script => @node.value[:preserve],
        :escape_html => @node.value[:escape_html], &block)
    end

    def compile_silent_script
      return if @options[:suppress_eval]
      push_silent(@node.value[:text])
      keyword = @node.value[:keyword]
      ruby_block = block_given? && !keyword

      if block_given?
        # Store these values because for conditional statements,
        # we want to restore them for each branch
        @node.value[:dont_indent_next_line] = @dont_indent_next_line
        @node.value[:dont_tab_up_next_text] = @dont_tab_up_next_text
        yield
        push_silent("end", :can_suppress) unless @node.value[:dont_push_end]
      elsif keyword == "end"
        if @node.parent.children.last.equal?(@node)
          # Since this "end" is ending the block,
          # we don't need to generate an additional one
          @node.parent.value[:dont_push_end] = true
        end
        # Don't restore dont_* for end because it isn't a conditional branch.
      elsif Parser::MID_BLOCK_KEYWORDS.include?(keyword)
        # Restore dont_* for this conditional branch
        @dont_indent_next_line = @node.parent.value[:dont_indent_next_line]
        @dont_tab_up_next_text = @node.parent.value[:dont_tab_up_next_text]
      end
    end

    def compile_haml_comment; end

    def compile_tag
      t = @node.value

      # Get rid of whitespace outside of the tag if we need to
      rstrip_buffer! if t[:nuke_outer_whitespace]

      dont_indent_next_line =
        (t[:nuke_outer_whitespace] && !block_given?) ||
        (t[:nuke_inner_whitespace] && block_given?)

      if @options[:suppress_eval]
        object_ref = "nil"
        parse = false
        value = t[:parse] ? nil : t[:value]
        attributes_hashes = {}
        preserve_script = false
      else
        object_ref = t[:object_ref]
        parse = t[:parse]
        value = t[:value]
        attributes_hashes = t[:attributes_hashes]
        preserve_script = t[:preserve_script]
      end

      # Check if we can render the tag directly to text and not process it in the buffer
      if object_ref == "nil" && attributes_hashes.empty? && !preserve_script
        tag_closed = !block_given? && !t[:self_closing] && !parse

        open_tag = prerender_tag(t[:name], t[:self_closing], t[:attributes])
        if tag_closed
          open_tag << "#{value}</#{t[:name]}>"
          open_tag << "\n" unless t[:nuke_outer_whitespace]
        elsif !(parse || t[:nuke_inner_whitespace] ||
            (t[:self_closing] && t[:nuke_outer_whitespace]))
          open_tag << "\n"
        end

        push_merged_text(open_tag,
          tag_closed || t[:self_closing] || t[:nuke_inner_whitespace] ? 0 : 1,
          !t[:nuke_outer_whitespace])

        @dont_indent_next_line = dont_indent_next_line
        return if tag_closed
      else
        if attributes_hashes.empty?
          attributes_hashes = ''
        elsif attributes_hashes.size == 1
          attributes_hashes = ", #{attributes_hashes.first}"
        else
          attributes_hashes = ", (#{attributes_hashes.join(").merge(")})"
        end

        push_merged_text "<#{t[:name]}", 0, !t[:nuke_outer_whitespace]
        push_generated_script(
          "_hamlout.attributes(#{inspect_obj(t[:attributes])}, #{object_ref}#{attributes_hashes})")
        concat_merged_text(
          if t[:self_closing] && xhtml?
            " />" + (t[:nuke_outer_whitespace] ? "" : "\n")
          else
            ">" + ((if t[:self_closing] && html?
                      t[:nuke_outer_whitespace]
                    else
                      !block_given? || t[:preserve_tag] || t[:nuke_inner_whitespace]
                    end) ? "" : "\n")
          end)

        if value && !parse
          concat_merged_text("#{value}</#{t[:name]}>#{t[:nuke_outer_whitespace] ? "" : "\n"}")
        else
          @to_merge << [:text, '', 1] unless t[:nuke_inner_whitespace]
        end

        @dont_indent_next_line = dont_indent_next_line
      end

      return if t[:self_closing]

      if value.nil?
        @output_tabs += 1 unless t[:nuke_inner_whitespace]
        yield if block_given?
        @output_tabs -= 1 unless t[:nuke_inner_whitespace]
        rstrip_buffer! if t[:nuke_inner_whitespace]
        push_merged_text("</#{t[:name]}>" + (t[:nuke_outer_whitespace] ? "" : "\n"),
          t[:nuke_inner_whitespace] ? 0 : -1, !t[:nuke_inner_whitespace])
        @dont_indent_next_line = t[:nuke_outer_whitespace]
        return
      end

      if parse
        push_script(value, t.merge(:in_tag => true))
        concat_merged_text("</#{t[:name]}>" + (t[:nuke_outer_whitespace] ? "" : "\n"))
      end
    end

    def compile_comment
      open = "<!--#{@node.value[:conditional]}"

      # Render it statically if possible
      unless block_given?
        push_text("#{open} #{@node.value[:text]} #{@node.value[:conditional] ? "<![endif]-->" : "-->"}")
        return
      end

      push_text(open, 1)
      @output_tabs += 1
      yield if block_given?
      @output_tabs -= 1
      push_text(@node.value[:conditional] ? "<![endif]-->" : "-->", -1)
    end

    def compile_doctype
      doctype = text_for_doctype
      push_text doctype if doctype
    end

    def compile_filter
      unless filter = Filters.defined[@node.value[:name]]
        raise Error.new("Filter \"#{@node.value[:name]}\" is not defined.", @node.line - 1)
      end
      filter.internal_compile(self, @node.value[:text])
    end

    def text_for_doctype
      if @node.value[:type] == "xml"
        return nil if html?
        wrapper = @options[:attr_wrapper]
        return "<?xml version=#{wrapper}1.0#{wrapper} encoding=#{wrapper}#{@node.value[:encoding] || "utf-8"}#{wrapper} ?>"
      end

      if html5?
        '<!DOCTYPE html>'
      else
        if xhtml?
          if @node.value[:version] == "1.1"
            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
          elsif @node.value[:version] == "5"
            '<!DOCTYPE html>'
          else
            case @node.value[:type]
            when "strict";   '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
            when "frameset"; '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
            when "mobile";   '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
            when "rdfa";     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
            when "basic";    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
            else             '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
            end
          end

        elsif html4?
          case @node.value[:type]
          when "strict";   '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
          when "frameset"; '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
          else             '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
          end
        end
      end
    end

    # Evaluates `text` in the context of the scope object, but
    # does not output the result.
    def push_silent(text, can_suppress = false)
      flush_merged_text
      return if can_suppress && options[:suppress_eval]
      @precompiled << "#{resolve_newlines}#{text}\n"
      @output_line += text.count("\n") + 1
    end

    # Adds `text` to `@buffer` with appropriate tabulation
    # without parsing it.
    def push_merged_text(text, tab_change = 0, indent = true)
      text = !indent || @dont_indent_next_line || @options[:ugly] ? text : "#{'  ' * @output_tabs}#{text}"
      @to_merge << [:text, text, tab_change]
      @dont_indent_next_line = false
    end

    # Concatenate `text` to `@buffer` without tabulation.
    def concat_merged_text(text)
      @to_merge << [:text, text, 0]
    end

    def push_text(text, tab_change = 0)
      push_merged_text("#{text}\n", tab_change)
    end

    def flush_merged_text
      return if @to_merge.empty?

      str = ""
      mtabs = 0
      @to_merge.each do |type, val, tabs|
        case type
        when :text
          str << inspect_obj(val)[1...-1]
          mtabs += tabs
        when :script
          if mtabs != 0 && !@options[:ugly]
            val = "_hamlout.adjust_tabs(#{mtabs}); " + val
          end
          str << "\#{#{val}}"
          mtabs = 0
        else
          raise SyntaxError.new("[HAML BUG] Undefined entry in Haml::Compiler@to_merge.")
        end
      end

      unless str.empty?
        @precompiled <<
          if @options[:ugly]
            "_hamlout.buffer << \"#{str}\";"
          else
            "_hamlout.push_text(\"#{str}\", #{mtabs}, #{@dont_tab_up_next_text.inspect});"
          end
      end
      @to_merge = []
      @dont_tab_up_next_text = false
    end

    # Causes `text` to be evaluated in the context of
    # the scope object and the result to be added to `@buffer`.
    #
    # If `opts[:preserve_script]` is true, Haml::Helpers#find_and_flatten is run on
    # the result before it is added to `@buffer`
    def push_script(text, opts = {})
      return if options[:suppress_eval]

      args = %w[preserve_script in_tag preserve_tag escape_html nuke_inner_whitespace]
      args.map! {|name| opts[name.to_sym]}
      args << !block_given? << @options[:ugly]

      no_format = @options[:ugly] &&
        !(opts[:preserve_script] || opts[:preserve_tag] || opts[:escape_html])
      output_expr = "(#{text}\n)"
      static_method = "_hamlout.#{static_method_name(:format_script, *args)}"

      # Prerender tabulation unless we're in a tag
      push_merged_text '' unless opts[:in_tag]

      unless block_given?
        push_generated_script(no_format ? "#{text}\n" : "#{static_method}(#{output_expr});")
        concat_merged_text("\n") unless opts[:in_tag] || opts[:nuke_inner_whitespace]
        return
      end

      flush_merged_text
      push_silent "haml_temp = #{text}"
      yield
      push_silent('end', :can_suppress) unless @node.value[:dont_push_end]
      @precompiled << "_hamlout.buffer << #{no_format ? "haml_temp.to_s;" : "#{static_method}(haml_temp);"}"
      concat_merged_text("\n") unless opts[:in_tag] || opts[:nuke_inner_whitespace] || @options[:ugly]
    end

    def push_generated_script(text)
      @to_merge << [:script, resolve_newlines + text]
      @output_line += text.count("\n")
    end

    # This is a class method so it can be accessed from Buffer.
    def self.build_attributes(is_html, attr_wrapper, escape_attrs, attributes = {})
      quote_escape = attr_wrapper == '"' ? "&quot;" : "&apos;"
      other_quote_char = attr_wrapper == '"' ? "'" : '"'

      if attributes['data'].is_a?(Hash)
        attributes = attributes.dup
        attributes =
          Haml::Util.map_keys(attributes.delete('data')) {|name| "data-#{name}"}.merge(attributes)
      end

      result = attributes.collect do |attr, value|
        next if value.nil?

        value = filter_and_join(value, ' ') if attr == 'class'
        value = filter_and_join(value, '_') if attr == 'id'

        if value == true
          next " #{attr}" if is_html
          next " #{attr}=#{attr_wrapper}#{attr}#{attr_wrapper}"
        elsif value == false
          next
        end

        escaped =
          if escape_attrs == :once
            Haml::Helpers.escape_once(value.to_s)
          elsif escape_attrs
            CGI.escapeHTML(value.to_s)
          else
            value.to_s
          end
        value = Haml::Helpers.preserve(escaped)
        if escape_attrs
          # We want to decide whether or not to escape quotes
          value = value.gsub('&quot;', '"')
          this_attr_wrapper = attr_wrapper
          if value.include? attr_wrapper
            if value.include? other_quote_char
              value = value.gsub(attr_wrapper, quote_escape)
            else
              this_attr_wrapper = other_quote_char
            end
          end
        else
          this_attr_wrapper = attr_wrapper
        end
        " #{attr}=#{this_attr_wrapper}#{value}#{this_attr_wrapper}"
      end
      result.compact.sort.join
    end

    def self.filter_and_join(value, separator)
      return "" if value == ""
      value = [value] unless value.is_a?(Array)
      value = value.flatten.collect {|item| item ? item.to_s : nil}.compact.join(separator)
      return !value.empty? && value
    end

    def prerender_tag(name, self_close, attributes)
      attributes_string = Compiler.build_attributes(
        html?, @options[:attr_wrapper], @options[:escape_attrs], attributes)
      "<#{name}#{attributes_string}#{self_close && xhtml? ? ' /' : ''}>"
    end

    def resolve_newlines
      diff = @node.line - @output_line
      return "" if diff <= 0
      @output_line = @node.line
      "\n" * [diff, 0].max
    end

    # Get rid of and whitespace at the end of the buffer
    # or the merged text
    def rstrip_buffer!(index = -1)
      last = @to_merge[index]
      if last.nil?
        push_silent("_hamlout.rstrip!", false)
        @dont_tab_up_next_text = true
        return
      end

      case last.first
      when :text
        last[1].rstrip!
        if last[1].empty?
          @to_merge.slice! index
          rstrip_buffer! index
        end
      when :script
        last[1].gsub!(/\(haml_temp, (.*?)\);$/, '(haml_temp.rstrip, \1);')
        rstrip_buffer! index - 1
      else
        raise SyntaxError.new("[HAML BUG] Undefined entry in Haml::Compiler@to_merge.")
      end
    end

    def compile(node)
      parent, @node = @node, node
      block = proc {node.children.each {|c| compile c}}
      send("compile_#{node.type}", &(block unless node.children.empty?))
    ensure
      @node = parent
    end
  end
end
