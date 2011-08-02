module DBI
    #
    # Represents a Time
    #
    # DEPRECATED: Please use a regular Time or DateTime object.
   class Time
      attr_accessor :hour, :minute, :second

      private
      # DBI::Time.new(hour = 0, minute = 0, second = 0)
      # DBI::Time.new(Time)
      #
      # Creates and returns a new DBI::Time object.  Unlike the Time object
      # in the standard library, accepts an hour, minute and second, or a
      # Time object.
      def initialize(hour=0, minute=0, second=0)
         case hour
            when ::Time
               @hour, @minute, @second = hour.hour, hour.min, hour.sec
               @original_time = hour
            else
               @hour, @minute, @second = hour, minute, second
         end
      end

      public
      
      deprecate :initialize, :public

      alias :min :minute
      alias :min= :minute=
      alias :sec :second
      alias :sec= :second=

      # Returns a new Time object based on the hour, minute and second, using
      # the current year, month and day.  If a Time object was passed to the
      # constructor, returns that object instead.
      def to_time
         if @original_time
            @original_time
         else
            t = ::Time.now
            ::Time.local(t.year, t.month, t.day, @hour, @minute, @second)
         end
      end

      # Returns a DBI::Time object as a string in HH:MM:SS format.
      def to_s
         sprintf("%02d:%02d:%02d", @hour, @minute, @second)
      end
   end
end
