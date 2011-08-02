module DBI
    #
    # Represents a Date.
    #
    # DEPRECATED: Please use a regular Date or DateTime object.
    #
    class Date
        attr_accessor :year, :month, :day

        # Aliases
        alias :mon :month
        alias :mon= :month=
        alias :mday :day
        alias :mday= :day=

        # Returns a new Time object based on the year, month and day or, if a
        # Time object was passed to the constructor, returns that object.
        def to_time
            @original_time || ::Time.local(@year, @month, @day, 0, 0, 0)
        end

        # Returns a new Date object based on the year, month and day or, if a
        # Date object was passed to the constructor, returns that object.
        def to_date
            @original_date || ::Date.new(@year, @month, @day)
        end

        # Returns a DBI::Date object as a string in YYYY-MM-DD format.
        def to_s
            sprintf("%04d-%02d-%02d", @year, @month, @day)
        end

        private 

        # DBI::Date.new(year = 0, month = 0, day = 0)
        # DBI::Date.new(Date)
        # DBI::Date.new(Time)
        #
        # Creates and returns a new DBI::Date object.  It's similar to the
        # standard Date class' constructor except that it also accepts a
        # Date or Time object.
        def initialize(year=0, month=0, day=0)
            case year
            when ::Date
                @year, @month, @day = year.year, year.month, year.day 
                @original_date = year
            when ::Time
                @year, @month, @day = year.year, year.month, year.day 
                @original_time = year
            else
                @year, @month, @day = year, month, day
            end
        end

        public

        deprecate :initialize, :public
    end
end
