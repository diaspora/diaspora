
module NewRelic
  module Stats
    
    # a stat is absent if its call count equals zero
    def absent?
      call_count == 0
    end
    
    # outputs a useful human-readable time given a value in milliseconds
    def time_str(value_ms)
      case
      when value_ms >= 10000
        "%.1f s" % (value_ms / 1000.0)
      when value_ms >= 5000
        "%.2f s" % (value_ms / 1000.0)
      else
        "%.0f ms" % value_ms
      end
    end

    # makes sure we aren't dividing by zero
    def checked_calculation(numerator, denominator)
      if denominator.nil? || denominator == 0
        0.0
      else
        numerator.to_f / denominator
      end
    end
    
    def average_call_time
      checked_calculation(total_call_time, call_count)
    end
    def average_exclusive_time
      checked_calculation(total_exclusive_time, call_count)
    end

    # merge by adding to average response time
    # - used to compose multiple metrics e.g. dispatcher time + mongrel queue time
    def sum_merge! (other_stats)
      Array(other_stats).each do |other|
        self.sum_attributes(other)
      end
      self
    end

    def sum_attributes(other)
      update_totals(other)
      stack_min_max_from(other)
      update_boundaries(other)
    end

    def stack_min_max_from(other)
      self.min_call_time += other.min_call_time
      self.max_call_time += other.max_call_time
    end

    def update_boundaries(other)
      self.begin_time = other.begin_time if should_replace_begin_time?(other)
      self.end_time = other.end_time if should_replace_end_time?(other)
    end

    def should_replace_end_time?(other)
      end_time.to_f < other.end_time.to_f
    end

    def should_replace_begin_time?(other)
      other.begin_time.to_f < begin_time.to_f || begin_time.to_f == 0.0
    end

    def update_totals(other)
      self.total_call_time      += other.total_call_time
      self.total_exclusive_time += other.total_exclusive_time
      self.sum_of_squares       += other.sum_of_squares
    end

    def min_time_less?(other)
      (other.min_call_time < min_call_time && other.call_count > 0) || call_count == 0
    end

    def expand_min_max_to(other)
        self.min_call_time = other.min_call_time if min_time_less?(other)
        self.max_call_time = other.max_call_time if other.max_call_time > max_call_time
    end

    def merge_attributes(other)
      update_totals(other)
      expand_min_max_to(other)
      self.call_count += other.call_count
      update_boundaries(other)
    end

    def merge!(other_stats)
      Array(other_stats).each do |other|
        merge_attributes(other)
      end

      self
    end

    def merge(other_stats)
      stats = self.clone
      stats.merge!(other_stats)
    end

    # split into an array of timeslices whose
    # time boundaries start on (begin_time + (n * duration)) and whose
    # end time ends on (begin_time * (n + 1) * duration), except for the
    # first and last elements, whose begin time and end time are the begin
    # and end times of this stats instance, respectively.  Yield to caller
    # for the code that creates the actual stats instance
    def split(rollup_begin_time, rollup_period)
      rollup_begin_time = rollup_begin_time.to_f
      rollup_begin_time += ((self.begin_time - rollup_begin_time) / rollup_period).floor * rollup_period

      current_begin_time = self.begin_time
      current_end_time = rollup_begin_time + rollup_period

      return [self] if current_end_time >= self.end_time

      timeslices = []
      while current_end_time < self.end_time do
        ts = yield(current_begin_time, current_end_time)
        if ts
          ts.fraction_of(self)
          timeslices << ts
        end
        current_begin_time = current_end_time
        current_end_time = current_begin_time + rollup_period
      end

      if self.end_time > current_begin_time
        percentage = rollup_period / self.duration + (self.begin_time - rollup_begin_time) / rollup_period
        ts = yield(current_begin_time, self.end_time)
        if ts
          ts.fraction_of(self)
          timeslices << ts
        end
      end

      timeslices
    end

    def is_reset?
      call_count == 0 && total_call_time == 0.0 && total_exclusive_time == 0.0
    end

    def reset
      self.call_count = 0
      self.total_call_time = 0.0
      self.total_exclusive_time = 0.0
      self.min_call_time = 0.0
      self.max_call_time = 0.0
      self.sum_of_squares = 0.0
      self.begin_time = Time.at(0)
      self.end_time = Time.at(0)
    end

    def as_percentage_of(other_stats)
      checked_calculation(total_call_time, other_stats.total_call_time) * 100.0
    end

    # the stat total_call_time is a percent
    def as_percentage
      average_call_time * 100.0
    end

    def duration
      end_time ? (end_time - begin_time) : 0.0
    end

    def midpoint
      begin_time + (duration/2)
    end
    def calls_per_minute
      checked_calculation(call_count, duration) * 60
    end

    def total_call_time_per_minute
      60.0 * time_percentage
    end

    def standard_deviation
      return 0 if call_count < 2 || self.sum_of_squares.nil?

      # Convert sum of squares into standard deviation based on
      # formula for the standard deviation for the entire population
      x = self.sum_of_squares - (self.call_count * (self.average_value**2))
      return 0 if x <= 0

      Math.sqrt(x / self.call_count)
    end

    # returns the time spent in this component as a percentage of the total
    # time window.
    def time_percentage
      checked_calculation(total_call_time, duration)
    end

    def exclusive_time_percentage
      checked_calculation(total_exclusive_time, duration)
    end

    alias average_value average_call_time
    alias average_response_time average_call_time
    alias requests_per_minute calls_per_minute

    def to_s
      summary
    end

    # Summary string to facilitate testing
    def summary
      format = "%m/%d/%y %I:%M%p"
      "[#{Time.at(begin_time.to_f).utc.strftime(format)} UTC, #{'%2.3fs' % duration.to_f}; #{'%2i' % call_count.to_i} calls #{'%4i' % average_call_time.to_f}s]"
    end

    # calculate this set of stats to be a percentage fraction
    # of the provided stats, which has an overlapping time window.
    # used as a key part of the split algorithm
    def fraction_of(s)
      min_end = (end_time < s.end_time ? end_time : s.end_time)
      max_begin = (begin_time > s.begin_time ? begin_time : s.begin_time)
      percentage = (min_end - max_begin) / s.duration

      self.total_exclusive_time = s.total_exclusive_time * percentage
      self.total_call_time = s.total_call_time * percentage
      self.min_call_time = s.min_call_time
      self.max_call_time = s.max_call_time
      self.call_count = s.call_count * percentage
      self.sum_of_squares = (s.sum_of_squares || 0) * percentage
    end

    # multiply the total time and rate by the given percentage
    def multiply_by(percentage)
      self.total_call_time = total_call_time * percentage
      self.call_count = call_count * percentage
      self.sum_of_squares = sum_of_squares * percentage

      self
    end

    # returns s,t,f
    def get_apdex
      [@call_count, @total_call_time.to_i, @total_exclusive_time.to_i]
    end

    def apdex_score
      s, t, f = get_apdex
      (s.to_f + (t.to_f / 2)) / (s+t+f).to_f
    end
  end


  class StatsBase
    include Stats

    attr_accessor :call_count
    attr_accessor :min_call_time
    attr_accessor :max_call_time
    attr_accessor :total_call_time
    attr_accessor :total_exclusive_time
    attr_accessor :sum_of_squares

    def initialize
      reset
    end

    def freeze
      @end_time = Time.now
      super
    end

    def to_json(*a)
      {'call_count' => call_count,
        'min_call_time' => min_call_time,
        'max_call_time' => max_call_time,
        'total_call_time' => total_call_time,
        'total_exclusive_time' => total_exclusive_time,
        'sum_of_squares' => sum_of_squares}.to_json(*a)
    end


    # In this class, we explicitly don't track begin and end time here, to save space during
    # cross process serialization via xml.  Still the accessor methods must be provided for merge to work.
    def begin_time=(t)
    end

    def end_time=(t)
    end

    def begin_time
      0.0
    end

    def end_time
      0.0
    end
  end


  class BasicStats < StatsBase
  end

  class ApdexStats < StatsBase

    def record_apdex_s
      @call_count += 1
    end

    def record_apdex_t
      @total_call_time += 1
    end

    def record_apdex_f
      @total_exclusive_time += 1
    end
  end

  # Statistics used to track the performance of traced methods
  class MethodTraceStats < StatsBase

    alias data_point_count call_count

    # record a single data point into the statistical gatherer.  The gatherer
    # will aggregate all data points collected over a specified period and upload
    # its data to the NewRelic server
    def record_data_point(value, exclusive_time = value)
      @call_count += 1
      @total_call_time += value
      @min_call_time = value if value < @min_call_time || @call_count == 1
      @max_call_time = value if value > @max_call_time
      @total_exclusive_time += exclusive_time

      @sum_of_squares += (value * value)
      self
    end

    alias trace_call record_data_point
    
    # Records multiple data points as one method call - this handles
    # all the aggregation that would be done with multiple
    # record_data_point calls
    def record_multiple_data_points(total_value, count=1)
      return record_data_point(total_value) if count == 1
      @call_count += count
      @total_call_time += total_value
      avg_val = total_value / count
      @min_call_time = avg_val if avg_val < @min_call_time || @call_count == count
      @max_call_time = avg_val if avg_val > @max_call_time
      @total_exclusive_time += total_value
      @sum_of_squares += (avg_val * avg_val) * count
      self
    end
    
    # increments the call_count by one
    def increment_count(value = 1)
      @call_count += value
    end
    
    # outputs a human-readable version of the MethodTraceStats object
    def inspect
      "#<NewRelic::MethodTraceStats #{summary} >"
    end

  end

  class ScopedMethodTraceStats < MethodTraceStats
    attr_accessor :unscoped_stats
    def initialize(unscoped_stats)
      super()
      self.unscoped_stats = unscoped_stats
    end
    def trace_call(call_time, exclusive_time = call_time)
      unscoped_stats.trace_call call_time, exclusive_time
      super call_time, exclusive_time
    end
    # Records multiple data points as one method call - this handles
    # all the aggregation that would be done with multiple
    # trace_call calls    
    def record_multiple_data_points(total_value, count=1)
      unscoped_stats.record_multiple_data_points(total_value, count)
      super total_value, count
    end
  end
end

