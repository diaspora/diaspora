# encoding: utf-8
require 'stringio'
require 'spec_helper'
require 'gherkin/parser/parser'
require 'gherkin/formatter/filter_formatter'
require 'gherkin/formatter/pretty_formatter'

module Gherkin
  module Formatter
    describe FilterFormatter do
      attr_accessor :file

      before do
        self.file = 'complex_for_filtering.feature'
      end

      def verify_filter(filters, *line_ranges)
        io = StringIO.new
        pretty_formatter = Gherkin::Formatter::PrettyFormatter.new(io, true, false)
        filter_formatter = Gherkin::Formatter::FilterFormatter.new(pretty_formatter, filters)
        parser = Gherkin::Parser::Parser.new(filter_formatter)

        path = File.dirname(__FILE__) + "/../fixtures/" + file
        source = File.new(path).read + "# __EOF__"
        parser.parse(source, path, 0)
        
        source_lines = source.split("\n")
        expected = (line_ranges.map do |line_range|
          source_lines[(line_range.first-1..line_range.last-1)]
        end.flatten).join("\n").gsub(/# __EOF__/, '')
        io.string.should == expected
      end

      context "tags" do
        it "should filter on feature tag" do
          verify_filter(['@tag1'], 1..61)
        end

        it "should filter on scenario tag" do
          verify_filter(['@tag4'], 1..19)
        end

        it "should filter on abother scenario tag" do
          verify_filter(['@tag3'], 1..37)
        end

        it "should filter on scenario outline tag" do
          verify_filter(['@more'], 1..14, 46..61)
        end

        it "should filter on first examples tag" do
          verify_filter(['@neat'], 1..14, 46..55)
        end

        it "should filter on second examples tag" do
          verify_filter(['@hamster'], 1..14, 46..49, 56..61)
        end

        it "should not replay examples from ignored scenario outline" do
          self.file = 'scenario_outline_with_tags.feature'
          verify_filter(['~@wip'], 1..2, 12..14)
        end
      end

      context "names" do
        it "should filter on scenario name" do
          verify_filter([/Reading a Scenario/], 1..19)
        end

        it "should filter on scenario outline name" do
          verify_filter([/More/], 1..14, 46..61)
        end

        it "should filter on first examples name" do
          verify_filter([/Neato/], 1..14, 46..55)
        end

        it "should filter on second examples name" do
          verify_filter([/Rodents/], 1..14, 46..49, 56..61)
        end

        it "should filter on various names" do
          self.file = 'hantu_pisang.feature'
          verify_filter([/Pisang/], 1..8, 19..32)
        end

        it "should filter on background name" do
          self.file = 'hantu_pisang.feature'
          verify_filter([/The background/], 1..5)
        end
      end

      context "lines" do
        context "on the same line as feature element keyword" do
          it "should filter on scenario without line" do
            self.file = 'scenario_without_steps.feature'
            verify_filter([3], 1..4)
          end

          it "should filter on scenario line" do
            verify_filter([16], 1..19)
          end

          it "should filter on scenario outline line" do
            verify_filter([47], 1..14, 46..61)
          end

          it "should filter on first examples line" do
            verify_filter([51], 1..14, 46..55)
          end

          it "should filter on second examples line" do
            verify_filter([57], 1..14, 46..49, 56..61)
          end
        end

        context "on the same line as step keyword" do
          it "should filter on step line" do
            verify_filter([17], 1..19)
          end

          it "should filter on scenario outline line" do
            verify_filter([48], 1..14, 46..61)
          end
        end

        context "on examples header line" do
          it "should filter on first table" do
            verify_filter([52], 1..14, 46..55)
          end

          it "should filter on second table" do
            verify_filter([58], 1..14, 46..49, 56..61)
          end
        end

        context "on examples example line" do
          it "should filter on first table" do
            verify_filter([53], 1..14, 46..53, 55..55)
          end
        end

        context "on tag line" do
          it "should filter on first tag" do
            verify_filter([15], 1..19)
          end
        end

        context "multiline argument" do
          it "should filter on table line" do
            verify_filter([36], 1..14, 20..37)
          end

          it "should filter on first pystring quote" do
            verify_filter([41], 1..14, 38..45)
          end

          it "should filter on last pystring quote" do
            verify_filter([44], 1..14, 38..45)
          end
        end
      end
    end
  end
end
