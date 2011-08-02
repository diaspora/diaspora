# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

# A very simple little class for doing some basic fast statistics sampling.
# You feed it either samples of numeric data you want measured or you call
# Stats.tick to get it to add a time delta between the last time you called it.
# When you're done either call sum, sumsq, n, min, max, mean or sd to get 
# the information.  The other option is to just call dump and see everything.
#
# It does all of this very fast and doesn't take up any memory since the samples
# are not stored but instead all the values are calculated on the fly.
module Mongrel
  class Stats
    attr_reader :sum, :sumsq, :n, :min, :max

    def initialize(name)
      @name = name
      reset
    end

    # Resets the internal counters so you can start sampling again.
    def reset
      @sum = 0.0
      @sumsq = 0.0
      @last_time = Time.new
      @n = 0.0
      @min = 0.0
      @max = 0.0
    end

    # Adds a sampling to the calculations.
    def sample(s)
      @sum += s
      @sumsq += s * s
      if @n == 0
        @min = @max = s
      else
        @min = s if @min > s
        @max = s if @max < s
      end
      @n+=1
    end

    # Dump this Stats object with an optional additional message.
    def dump(msg = "", out=STDERR)
      out.puts "#{msg}: #{self.to_s}"
    end

    # Returns a common display (used by dump)
    def to_s  
    "[#{@name}]: SUM=%0.4f, SUMSQ=%0.4f, N=%0.4f, MEAN=%0.4f, SD=%0.4f, MIN=%0.4f, MAX=%0.4f" % [@sum, @sumsq, @n, mean, sd, @min, @max]
    end


    # Calculates and returns the mean for the data passed so far.
    def mean
      @sum / @n
    end

    # Calculates the standard deviation of the data so far.
    def sd
      # (sqrt( ((s).sumsq - ( (s).sum * (s).sum / (s).n)) / ((s).n-1) ))
      begin
        return Math.sqrt( (@sumsq - ( @sum * @sum / @n)) / (@n-1) )
      rescue Errno::EDOM
        return 0.0
      end
    end


    # Adds a time delta between now and the last time you called this.  This
    # will give you the average time between two activities.
    # 
    # An example is:
    #
    #  t = Stats.new("do_stuff")
    #  10000.times { do_stuff(); t.tick }
    #  t.dump("time")
    #
    def tick
      now = Time.now
      sample(now - @last_time)
      @last_time = now
    end
  end
end
