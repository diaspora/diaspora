require 'cucumber/formatter/io'
require 'cucumber/formatter/pretty'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format tag_cloud</tt>
    # Custom formatter that prints a tag cloud as a table.
    class TagCloud
      include Io

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "tag_cloud")
        @options = options
        @counts = Hash.new{|h,k| h[k] = 0}
      end

      def after_features(features)
        print_summary(features)
      end

      def tag_name(tag_name)
        @counts[tag_name] += 1
      end
      
      private
  
      def print_summary(features)
        matrix = @counts.to_a.sort{|paira, pairb| paira[0] <=> pairb[0]}.transpose
        table = Cucumber::Ast::Table.new(matrix)
        formatter = Cucumber::Formatter::Pretty.new(@step_mother, @io, {})
        Cucumber::Ast::TreeWalker.new(@step_mother, [formatter]).visit_multiline_arg(table)
      end
    end
  end
end