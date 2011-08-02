require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/io'
require 'fileutils'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format junit</tt>
    class Junit
      include Io
      
      class UnNamedFeatureError < StandardError
        def initialize(feature_file)
          super("The feature in '#{feature_file}' does not have a name. The JUnit XML format requires a name for the testsuite element.")
        end
      end
      
      def initialize(step_mother, io, options)
        @reportdir = ensure_dir(io, "junit")
        @options = options
      end

      def before_feature(feature)
        @current_feature = feature
        @failures = @errors = @tests = @skipped = 0
        @builder = OrderedXmlMarkup.new( :indent => 2 )
        @time = 0
      end
      
      def before_feature_element(feature_element)
        @in_examples = Ast::ScenarioOutline === feature_element
      end
      
      def after_feature(feature)
        @testsuite = OrderedXmlMarkup.new( :indent => 2 )
        @testsuite.instruct!
        @testsuite.testsuite(
          :failures => @failures,
          :errors => @errors,
          :skipped => @skipped,
          :tests => @tests,
          :time => "%.6f" % @time,
          :name => @feature_name ) do
          @testsuite << @builder.target!
        end

        write_file(feature_result_filename(feature.file), @testsuite.target!)
      end

      def before_background(*args)
        @in_background = true
      end
      
      def after_background(*args)
        @in_background = false
      end

      def feature_name(keyword, name)
        raise UnNamedFeatureError.new(@current_feature.file) if name.empty?
        lines = name.split(/\r?\n/)
        @feature_name = lines[0]
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @scenario = (name.nil? || name == "") ? "Unnamed scenario" : name.split("\n")[0]
        @output = "#{keyword}: #{@scenario}\n\n"
      end

      def before_steps(steps)
        @steps_start = Time.now
      end
      
      def after_steps(steps)
        return if @in_background || @in_examples
        
        duration = Time.now - @steps_start
        if steps.failed?
          steps.each { |step| @output += "#{step.keyword}#{step.name}\n" }
          @output += "\nMessage:\n"
        end
        build_testcase(duration, steps.status, steps.exception)
      end
      
      def before_examples(*args)
        @header_row = true
        @in_examples = true
      end
      
      def after_examples(*args)
        @in_examples = false
      end

      def before_table_row(table_row)
        return unless @in_examples

        @table_start = Time.now
      end

      def after_table_row(table_row)
        return unless @in_examples and Cucumber::Ast::OutlineTable::ExampleRow === table_row
        duration = Time.now - @table_start
        unless @header_row
          name_suffix = " (outline example : #{table_row.name})"
          if table_row.failed?
            @output += "Example row: #{table_row.name}\n"
            @output += "\nMessage:\n"
          end
          build_testcase(duration, table_row.status, table_row.exception, name_suffix)
        end
        
        @header_row = false if @header_row
      end

      private

      def build_testcase(duration, status, exception = nil, suffix = "")
        @time += duration
        classname = "#{@feature_name}.#{@scenario}"
        name = "#{@scenario}#{suffix}"
        pending = [:pending, :undefined].include?(status)
        passed = (status == :passed || (pending && !@options[:strict]))

        @builder.testcase(:classname => classname, :name => name, :time => "%.6f" % duration) do
          unless passed
            @builder.failure(:message => "#{status.to_s} #{name}", :type => status.to_s) do
              @builder.cdata! @output
              @builder.cdata!(format_exception(exception)) if exception
            end
            @failures += 1
          end
          if passed and (status == :skipped || pending)
            @builder.skipped
            @skipped += 1
          end
        end
        @tests += 1
      end

      def format_exception(exception)
        (["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n")
      end
      
      def feature_result_filename(feature_file)
        File.join(@reportdir, "TEST-#{basename(feature_file)}.xml")
      end
      
      def basename(feature_file)
        File.basename(feature_file.gsub(/[\\\/]/, '-'), '.feature')
      end
      
      def write_file(feature_filename, data)
        File.open(feature_filename, 'w') { |file| file.write(data) }
      end
    end
  end
end
