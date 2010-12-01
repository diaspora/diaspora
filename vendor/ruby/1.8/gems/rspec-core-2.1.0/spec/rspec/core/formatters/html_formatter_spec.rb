require 'spec_helper'
require 'rspec/core/formatters/html_formatter'
require 'nokogiri'

module RSpec
  module Core
    module Formatters
      describe HtmlFormatter do
        let(:jruby?) { ::RUBY_PLATFORM == 'java' }
        let(:root)   { File.expand_path("#{File.dirname(__FILE__)}/../../../..") }
        let(:suffix) { jruby? ? '-jruby' : '' }

        let(:expected_file) do
          "#{File.dirname(__FILE__)}/html_formatted-#{::RUBY_VERSION}#{suffix}.html"
        end

        let(:generated_html) do
          options = RSpec::Core::ConfigurationOptions.new(
            %w[spec/rspec/core/resources/formatter_specs.rb --format html]
          )
          options.parse_options
          err, out = StringIO.new, StringIO.new
          command_line = RSpec::Core::CommandLine.new(options)
          command_line.run(err, out)
          out.string.gsub /\d+\.\d+ seconds/, 'x seconds'
        end

        let(:expected_html) do
          unless File.file?(expected_file)
            raise "There is no HTML file with expected content for this platform: #{expected_file}"
          end
          File.read(expected_file)
        end

        before do
          RSpec.configuration.stub(:load_spec_files) do
            RSpec.configuration.files_to_run.map {|f| load File.expand_path(f) }
          end
        end

        # Uncomment this group temporarily in order to overwrite the expected
        # with actual.  Use with care!!!
        # describe "file generator" do
          # it "generates a new comparison file" do
            # Dir.chdir(root) do
              # File.open(expected_file, 'w') {|io| io.write(generated_html)}
            # end
          # end
        # end

        def extract_backtrace_from(doc)
          backtrace = doc.search("div.backtrace").
            collect {|e| e.at("pre").inner_html}.
            collect {|e| e.split("\n")}.flatten.
            select  {|e| e =~ /formatter_specs\.rb/}
        end

        it "produces HTML identical to the one we designed manually" do
          Dir.chdir(root) do
            actual_doc = Nokogiri::HTML(generated_html)
            actual_backtraces = extract_backtrace_from(actual_doc)
            actual_doc.css("div.backtrace").remove

            expected_doc = Nokogiri::HTML(expected_html)
            expected_backtraces = extract_backtrace_from(expected_doc)
            expected_doc.search("div.backtrace").remove

            actual_doc.inner_html.should == expected_doc.inner_html

            expected_backtraces.each_with_index do |expected_line, i|
              expected_path, expected_line_number, expected_suffix = expected_line.split(':')
              actual_path, actual_line_number, actual_suffix = actual_backtraces[i].split(':')
              File.expand_path(actual_path).should == File.expand_path(expected_path)
              actual_line_number.should == expected_line_number
            end
          end
        end
      end
    end
  end
end
