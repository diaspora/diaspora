require 'spec_helper'
require 'rspec/core/formatters/text_mate_formatter'
require 'nokogiri'

module RSpec
  module Core
    module Formatters
      describe TextMateFormatter do
        let(:jruby?) { ::RUBY_PLATFORM == 'java' }
        let(:root)   { File.expand_path("#{File.dirname(__FILE__)}/../../../..") }
        let(:suffix) { jruby? ? '-jruby' : '' }

        let(:expected_file) do
          "#{File.dirname(__FILE__)}/text_mate_formatted-#{::RUBY_VERSION}#{suffix}.html"
        end

        let(:generated_html) do
          options = RSpec::Core::ConfigurationOptions.new(
            %w[spec/rspec/core/resources/formatter_specs.rb --format textmate]
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

        it "produces HTML identical to the one we designed manually" do
          Dir.chdir(root) do
            actual_doc = Nokogiri::HTML(generated_html)
            backtrace_lines = actual_doc.search("div.backtrace a")
            actual_doc.search("div.backtrace").remove

            expected_doc = Nokogiri::HTML(expected_html)
            expected_doc.search("div.backtrace").remove

            actual_doc.inner_html.should == expected_doc.inner_html

            backtrace_lines.each do |backtrace_line|
              backtrace_line['href'].should include("txmt://open?url=")
            end
          end
        end

        it "has a backtrace line from the raw erb evaluation" do
          Dir.chdir(root) do
            actual_doc = Nokogiri::HTML(generated_html)

            actual_doc.inner_html.should include('(erb):1')
          end
        end

        it "has a backtrace line from a erb source file we forced to appear" do
          generated_html.should include('open?url=file:///foo.html.erb')
        end

      end
    end
  end
end
