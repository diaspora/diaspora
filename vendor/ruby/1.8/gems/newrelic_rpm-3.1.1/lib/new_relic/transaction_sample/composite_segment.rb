require 'new_relic/transaction_sample'
require 'new_relic/transaction_sample/segment'
require 'new_relic/transaction_sample/summary_segment'
module NewRelic
  class TransactionSample
    class CompositeSegment < Segment
      attr_reader :detail_segments

      def initialize(segments)
        summary = SummarySegment.new(segments.first)
        super summary.entry_timestamp, "Repeating pattern (#{segments.length} repeats)", nil

        summary.end_trace(segments.last.exit_timestamp)

        @detail_segments = segments.clone

        add_called_segment(summary)
        end_trace summary.exit_timestamp
      end

      def detail_segments=(segments)
        @detail_segments = segments
      end

    end
  end
end
