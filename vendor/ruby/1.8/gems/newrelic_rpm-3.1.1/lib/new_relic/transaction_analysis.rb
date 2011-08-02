require 'new_relic/transaction_analysis/segment_summary'
# Add these methods to TransactionSample that enable performance analysis in the user interface.
module NewRelic
  module TransactionAnalysis
    def database_time
      time_percentage(/^Database\/.*/)
    end

    def render_time
      time_percentage(/^View\/.*/)
    end

    # return the data that breaks down the performance of the transaction
    # as an array of SegmentSummary objects.  If a limit is specified, then
    # limit the data set to the top n
    def breakdown_data(limit = nil)
      metric_hash = {}
      each_segment_with_nest_tracking do |segment|
        unless segment == root_segment
          metric_name = segment.metric_name
          metric_hash[metric_name] ||= SegmentSummary.new(metric_name, self)
          metric_hash[metric_name] << segment
          metric_hash[metric_name]
        end
      end

      data = metric_hash.values

      data.sort! do |x,y|
        y.exclusive_time <=> x.exclusive_time
      end

      if limit && data.length > limit
        data = data[0..limit - 1]
      end

      # add one last segment for the remaining time if any
      remainder = duration
      data.each do |segment|
        remainder -= segment.exclusive_time
      end

      if (remainder*1000).round > 0
        remainder_summary = SegmentSummary.new('Remainder', self)
        remainder_summary.total_time = remainder_summary.exclusive_time = remainder
        remainder_summary.call_count = 1
        data << remainder_summary
      end

      data
    end

    # return an array of sql statements executed by this transaction
    # each element in the array contains [sql, parent_segment_metric_name, duration]
    def sql_segments(show_non_sql_segments = true)
      segments = []
      each_segment do |segment|
        segments << segment if segment[:sql] || segment[:sql_obfuscated] || (show_non_sql_segments && segment[:key])
      end
      segments
    end

    private
    def time_percentage(regex)
      total = 0
      each_segment do |segment|
        if regex =~ segment.metric_name
          total += segment.duration
        end
      end
      fraction = 100.0 * total / duration
      # percent value rounded to two digits:
      return (100 * fraction).round / 100.0
    end
  end
end

