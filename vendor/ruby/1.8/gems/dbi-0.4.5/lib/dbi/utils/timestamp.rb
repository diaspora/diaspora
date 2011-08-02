module DBI
    #
    # Represents a Timestamp.
    #
    # DEPRECATED: Please use a regular DateTime object.
    #
   class Timestamp
      attr_accessor :year, :month, :day
      attr_accessor :hour, :minute, :second
      attr_writer   :fraction

      private
      # DBI::Timestamp(year=0,month=0,day=0,hour=0,min=0,sec=0,fraction=nil)
      # DBI::Timestamp(Time)
      # DBI::Timestamp(Date)
      #
      # Creates and returns a new DBI::Timestamp object.  This is similar to
      # a Time object in the standard library, but it also contains fractional
      # seconds, expressed in nanoseconds.  In addition, the constructor
      # accepts either a Date or Time object.
      def initialize(year=0, month=0, day=0, hour=0, min=0, sec=0, fraction=nil)
         case year
            when ::Time
               @year, @month, @day = year.year, year.month, year.day 
               @hour, @minute, @second, @fraction = year.hour, year.min, year.sec, nil 
               @original_time = year
            when ::Date
               @year, @month, @day = year.year, year.month, year.day 
               @hour, @minute, @second, @fraction = 0, 0, 0, nil 
               @original_date = year
            else
               @year, @month, @day = year, month, day
               @hour, @minute, @second, @fraction = hour, min, sec, fraction
         end
      end

      public
      
      deprecate :initialize, :public

      # Returns true if +timestamp+ has a year, month, day, hour, minute,
      # second and fraction equal to the comparing object.
      #
      # Returns false if the comparison fails for any reason.
      def ==(timestamp)
         @year == timestamp.year and @month == timestamp.month and
         @day == timestamp.day and @hour == timestamp.hour and
         @minute == timestamp.minute and @second == timestamp.second and
         (fraction() == timestamp.fraction)
      rescue
         false
      end

      # Returns fractional seconds, or 0 if not set.
      def fraction
         @fraction || 0
      end

      # Aliases
      alias :mon :month
      alias :mon= :month=
      alias :mday :day
      alias :mday= :day=
      alias :min :minute
      alias :min= :minute=
      alias :sec :second
      alias :sec= :second=

      # Returns a DBI::Timestamp object as a string in YYYY-MM-DD HH:MM:SS
      # format.  If a fraction is present, then it is appended in ".FF" format.
      def to_s
         string = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
             @year, @month, @day, @hour, @minute, @second) 

         if @fraction
            fraction = ("%.9f" % (@fraction.to_i / 1e9)).
                        to_s[1..-1].gsub(/0{1,8}$/, "")
            string += fraction
         end

         string
      end

      # Returns a new Time object based on the year, month and day or, if a
      # Time object was passed to the constructor, returns that object.
      def to_time
         @original_time || ::Time.local(@year, @month, @day, @hour, @minute, @second)
      end

      # Returns a new Date object based on the year, month and day or, if a
      # Date object was passed to the constructor, returns that object.
      def to_date
         @original_date || ::Date.new(@year, @month, @day)
      end
   end
end
