require 'fileutils'
require 'cucumber/formatter/console'
require 'cucumber/formatter/io'
require 'gherkin/formatter/escaping'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format pretty</tt> (the default formatter).
    #
    # This formatter prints features to plain text - exactly how they were parsed,
    # just prettier. That means with proper indentation and alignment of table columns.
    #
    # If the output is STDOUT (and not a file), there are bright colours to watch too.
    #
    class Pretty
      include FileUtils
      include Console
      include Io
      include Gherkin::Formatter::Escaping
      attr_writer :indent
      attr_reader :step_mother

      def initialize(step_mother, path_or_io, options)
        @step_mother, @io, @options = step_mother, ensure_io(path_or_io, "pretty"), options
        @exceptions = []
        @indent = 0
        @prefixes = options[:prefixes] || {}
        @delayed_announcements = []
      end

      def after_features(features)
        print_summary(features) unless @options[:autoformat]
      end

      def before_feature(feature)
        @exceptions = []
        @indent = 0
        if @options[:autoformat]
          file = File.join(@options[:autoformat], feature.file)
          dir = File.dirname(file)
          mkdir_p(dir) unless File.directory?(dir)
          @io = ensure_file(file, "pretty")
        end
      end
      
      def comment_line(comment_line)
        @io.puts(comment_line.indent(@indent))
        @io.flush
      end

      def after_tags(tags)
        if @indent == 1
          @io.puts
          @io.flush
        end
      end

      def tag_name(tag_name)
        tag = format_string(tag_name, :tag).indent(@indent)
        @io.print(tag)
        @io.flush
        @indent = 1
      end

      def feature_name(keyword, name)
        @io.puts("#{keyword}: #{name}")
        @io.puts
        @io.flush
      end

      def before_feature_element(feature_element)
        @indent = 2
        @scenario_indent = 2
      end
      
      def after_feature_element(feature_element)
        @io.puts
        @io.flush
      end

      def before_background(background)
        @indent = 2
        @scenario_indent = 2
        @in_background = true
      end

      def after_background(background)
        @in_background = nil
        @io.puts
        @io.flush
      end

      def background_name(keyword, name, file_colon_line, source_indent)        
        print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def before_examples_array(examples_array)
        @indent = 4
        @io.puts
        @visiting_first_example_name = true
      end
      
      def examples_name(keyword, name)
        puts unless @visiting_first_example_name
        @visiting_first_example_name = false
        names = name.strip.empty? ? [name.strip] : name.split("\n")
        @io.puts("    #{keyword}: #{names[0]}")
        names[1..-1].each {|s| @io.puts "      #{s}" } unless names.empty?
        @io.flush
        @indent = 6
        @scenario_indent = 6
      end
      
      def before_outline_table(outline_table)
        @table = outline_table
      end

      def after_outline_table(outline_table)
        @table = nil
        @indent = 4
      end
      
      def scenario_name(keyword, name, file_colon_line, source_indent)
        print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def before_step(step)
        @current_step = step
        @indent = 6
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
      end

      def step_name(keyword, step_match, status, source_indent, background)
        return if @hide_this_step
        source_indent = nil unless @options[:source]
        name_to_report = format_step(keyword, step_match, status, source_indent)
        @io.puts(name_to_report.indent(@scenario_indent + 2))
        print_announcements
      end

      def py_string(string)
        return if @hide_this_step
        s = %{"""\n#{string}\n"""}.indent(@indent)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}.join("\n")
        @io.puts(format_string(s, @current_step.status))
        @io.flush
      end

      def exception(exception, status)
        return if @hide_this_step
        print_exception(exception, status, @indent)
        @io.flush
      end

      def before_multiline_arg(multiline_arg)
        return if @options[:no_multiline] || @hide_this_step
        @table = multiline_arg
      end
      
      def after_multiline_arg(multiline_arg)
        @table = nil
      end

      def before_table_row(table_row)
        return if !@table || @hide_this_step
        @col_index = 0
        @io.print '  |'.indent(@indent-2)
      end

      def after_table_row(table_row)
        return if !@table || @hide_this_step
        print_table_row_announcements
        @io.puts
        if table_row.exception && !@exceptions.include?(table_row.exception)
          print_exception(table_row.exception, table_row.status, @indent)
        end
      end

      def after_table_cell(cell)
        return unless @table
        @col_index += 1
      end

      def table_cell_value(value, status)
        return if !@table || @hide_this_step
        status ||= @status || :passed
        width = @table.col_width(@col_index)
        cell_text = escape_cell(value.to_s || '')
        padded = cell_text + (' ' * (width - cell_text.unpack('U*').length))
        prefix = cell_prefix(status)
        @io.print(' ' + format_string("#{prefix}#{padded}", status) + ::Term::ANSIColor.reset(" |"))
        @io.flush
      end

      private
      
      def print_feature_element_name(keyword, name, file_colon_line, source_indent)
        @io.puts if @scenario_indent == 6
        names = name.empty? ? [name] : name.split("\n")
        line = "#{keyword}: #{names[0]}".indent(@scenario_indent)
        @io.print(line)
        if @options[:source]
          line_comment = " # #{file_colon_line}".indent(source_indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
        names[1..-1].each {|s| @io.puts "    #{s}"}
        @io.flush        
      end

      def cell_prefix(status)
        @prefixes[status]
      end

      def print_summary(features)
        print_stats(features, @options.custom_profiles)
        print_snippets(@options)
        print_passing_wip(@options)
      end
    end
  end
end
