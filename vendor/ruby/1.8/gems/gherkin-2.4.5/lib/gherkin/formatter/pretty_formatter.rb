# encoding: utf-8
require 'gherkin/formatter/ansi_escapes'
require 'gherkin/formatter/step_printer'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/escaping'
require 'gherkin/formatter/model'
require 'gherkin/native'

module Gherkin
  module Formatter
    class PrettyFormatter
      native_impl('gherkin')

      include AnsiEscapes
      include Escaping

      def initialize(io, monochrome, executing)
        @io = io
        @step_printer = StepPrinter.new
        @monochrome = monochrome
        @executing = executing
        @background = nil
        @tag_statement = nil
        @steps = []
      end

      def uri(uri)
        @uri = uri
      end

      def feature(feature)
        print_comments(feature.comments, '')
        print_tags(feature.tags, '')
        @io.puts "#{feature.keyword}: #{feature.name}"
        print_description(feature.description, '  ', false)
      end

      def background(background)
        replay
        @statement = background
      end

      def scenario(scenario)
        replay
        @statement = scenario
      end

      def scenario_outline(scenario_outline)
        replay
        @statement = scenario_outline
      end
      
      def replay
        print_statement
        print_steps
      end
      
      def print_statement
        return if @statement.nil?
        calculate_location_indentations
        @io.puts
        print_comments(@statement.comments, '  ')
        print_tags(@statement.tags, '  ') if @statement.respond_to?(:tags) # Background doesn't
        @io.write "  #{@statement.keyword}: #{@statement.name}"
        location = @executing ? "#{@uri}:#{@statement.line}" : nil
        @io.puts indented_location(location, true)
        print_description(@statement.description, '    ')
        @statement = nil
      end

      def print_steps
        while(@steps.any?)
          print_step('skipped', [], nil, true)
        end
      end

      def examples(examples)
        replay
        @io.puts
        print_comments(examples.comments, '    ')
        print_tags(examples.tags, '    ')
        @io.puts "    #{examples.keyword}: #{examples.name}"
        print_description(examples.description, '      ')
        table(examples.rows)
      end

      def step(step)
        @steps << step
      end

      def match(match)
        @match = match
        print_statement
        print_step('executing', @match.arguments, @match.location, false)
      end

      def result(result)
        @io.write(up(1))
        print_step(result.status, @match.arguments, @match.location, true)
      end

      def print_step(status, arguments, location, proceed)
        step = proceed ? @steps.shift : @steps[0]
        
        text_format = format(status)
        arg_format = arg_format(status)
        
        print_comments(step.comments, '    ')
        @io.write('    ')
        @io.write(text_format.text(step.keyword))
        @step_printer.write_step(@io, text_format, arg_format, step.name, arguments)
        @io.puts(indented_location(location, proceed))
        case step.multiline_arg
        when Model::DocString
          doc_string(step.multiline_arg)
        when Array
          table(step.multiline_arg)
        end
      end

      class MonochromeFormat
        def text(text)
          text
        end
      end

      class ColorFormat
        include AnsiEscapes
        
        def initialize(status)
          @status = status
        end

        def text(text)
          self.__send__(@status) + text + reset
        end
      end

      def arg_format(key)
        format("#{key}_arg")
      end

      def format(key)
        if @formats.nil?
          if @monochrome
            @formats = Hash.new(MonochromeFormat.new)
          else
            @formats = Hash.new do |formats, status|
              formats[status] = ColorFormat.new(status)
            end
          end
        end
        @formats[key]
      end

      def eof
        replay
        # NO-OP
      end

      def table(rows)
        cell_lengths = rows.map do |row| 
          row.cells.map do |cell| 
            escape_cell(cell).unpack("U*").length
          end
        end
        max_lengths = cell_lengths.transpose.map { |col_lengths| col_lengths.max }.flatten

        rows.each_with_index do |row, i|
          row.comments.each do |comment|
            @io.puts "      #{comment.value}"
          end
          j = -1
          @io.puts '      | ' + row.cells.zip(max_lengths).map { |cell, max_length|
            j += 1
            color(cell, nil, j) + ' ' * (max_length - cell_lengths[i][j])
          }.join(' | ') + ' |'
        end
      end

    private

      def doc_string(doc_string)
        @io.puts "      \"\"\"\n" + escape_triple_quotes(indent(doc_string.value, '      ')) + "\n      \"\"\""
      end

      def exception(exception)
        exception_text = "#{exception.message} (#{exception.class})\n#{(exception.backtrace || []).join("\n")}".gsub(/^/, '      ')
        @io.puts(failed(exception_text))
      end

      def color(cell, statuses, col)
        if statuses
          self.__send__(statuses[col], escape_cell(cell)) + reset
        else
          escape_cell(cell)
        end
      end

      if(RUBY_VERSION =~ /^1\.9/)
        START = /#{'^'.encode('UTF-8')}/
        TRIPLE_QUOTES = /#{'"""'.encode('UTF-8')}/
      else
        START = /^/
        TRIPLE_QUOTES = /"""/
      end

      def indent(string, indentation)
        string.gsub(START, indentation)
      end

      def escape_triple_quotes(s)
        s.gsub(TRIPLE_QUOTES, '\"\"\"')
      end

      def print_tags(tags, indent)
        @io.write(tags.empty? ? '' : indent + tags.map{|tag| tag.name}.join(' ') + "\n")
      end

      def print_comments(comments, indent)
        @io.write(comments.empty? ? '' : indent + comments.map{|comment| comment.value}.join("\n#{indent}") + "\n")
      end

      def print_description(description, indent, newline=true)
        if description != ""
          @io.puts indent(description, indent)
          @io.puts if newline
        end
      end

      def indented_location(location, proceed)
        indentation = proceed ? @indentations.shift : @indentations[0]
        location ? (' ' * indentation + ' ' + comments + "# #{location}" + reset) : ''
      end

      def calculate_location_indentations
        line_widths = ([@statement] + @steps).map {|step| (step.keyword+step.name).unpack("U*").length}
        max_line_width = line_widths.max
        @indentations = line_widths.map{|w| max_line_width - w}
      end
    end
  end
end
