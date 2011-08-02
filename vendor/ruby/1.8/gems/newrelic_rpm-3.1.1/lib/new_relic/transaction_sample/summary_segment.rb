require 'new_relic/transaction_sample'
require 'new_relic/transaction_sample/segment'
module NewRelic
  class TransactionSample
    class SummarySegment < Segment
      def initialize(segment)
        super segment.entry_timestamp, segment.metric_name, nil

        add_segments segment.called_segments

        end_trace segment.exit_timestamp
      end

      def add_segments(segments)
        segments.collect do |segment|
          SummarySegment.new(segment)
        end.each {|segment| add_called_segment(segment)}
      end
    end
  end
end
