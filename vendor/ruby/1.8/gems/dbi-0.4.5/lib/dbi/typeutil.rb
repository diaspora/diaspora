module DBI
    #
    # TypeUtil is a series of utility methods for type management.
    #
    class TypeUtil
        @@conversions = { }

        #
        # Register a conversion for a DBD. This applies to bound parameters for
        # outgoing statements; please look at DBI::Type for result sets.
        #
        # Conversions are given a driver_name, which is then used to look up
        # the conversion to perform on the object. Please see #convert for more
        # information. Driver names are typically provided by the DBD, but may
        # be overridden at any stage temporarily by assigning to the
        # +driver_name+ attribute for the various handles.
        #
        # A conversion block is normally a +case+ statement that identifies
        # various native ruby types and converts them to string, but ultimately
        # the result type is dependent on low-level driver. The resulting
        # object will be fed to the query as the bound value. 
        #
        # The result of the block is two arguments, the first being the result
        # object, and the second being a +cascade+ flag, which if true
        # instructs #convert to run the result through the +default+ conversion
        # as well and use its result. This is advantageous when you just need
        # to convert everything to string, and allow +default+ to properly escape
        # it.
        #
        def self.register_conversion(driver_name, &block)
            raise "Must provide a block" unless block_given?
            @@conversions[driver_name] = block
        end

        #
        # Convert object for +driver_name+. See #register_conversion for a
        # complete explanation of how type conversion is performed.
        #
        # If the conversion is instructed to cascade, it will go to the special
        # "default" conversion, which is a pre-defined common case (and
        # mutable) ruleset for native types. Note that it will use the result
        # from the first conversion, not what was originally passed. Be sure to
        # leave the object untouched if that is your intent. E.g., if your DBD
        # converts an Integer to String and tells it to cascade, the "default"
        # conversion will get a String and quote it, not an Integer (which has
        # different rules).
        #
        def self.convert(driver_name, obj)
            if @@conversions[driver_name]
                newobj, cascade = @@conversions[driver_name].call(obj)
                if cascade
                    return @@conversions["default"].call(newobj)
                end
                return newobj
            end

            return @@conversions["default"].call(obj)
        end

        # 
        # Convenience method to match many SQL named types to DBI::Type classes. If
        # none can be matched, returns DBI::Type::Varchar.
        #
        def self.type_name_to_module(type_name)
            case type_name
            when /^int(?:\d+|eger)?$/i
                DBI::Type::Integer
            when /^varchar$/i, /^character varying$/i
                DBI::Type::Varchar
            when /^(?:float|real)$/i
                DBI::Type::Float
            when /^bool(?:ean)?$/i, /^tinyint$/i
                DBI::Type::Boolean
            when /^time(?:stamp(?:tz)?)?$/i
                DBI::Type::Timestamp
            when /^(?:decimal|numeric)$/i
                DBI::Type::Decimal
            else
                DBI::Type::Varchar
            end
        end
    end
end

DBI::TypeUtil.register_conversion("default") do |obj|
    case obj
    when DBI::Binary # these need to be handled specially by the driver
        obj
    when ::NilClass
        nil
    when ::TrueClass
        "'1'"
    when ::FalseClass
        "'0'"
    when ::Time, ::Date, ::DateTime
        "'#{::DateTime.parse(obj.to_s).strftime("%Y-%m-%dT%H:%M:%S")}'"
    when ::String, ::Symbol
        obj = obj.to_s
        obj = obj.gsub(/\\/) { "\\\\" }
        obj = obj.gsub(/'/) { "''" }
        "'#{obj}'"
    when ::BigDecimal
        obj.to_s("F")
    when ::Numeric
        obj.to_s
    else
        "'#{obj.to_s}'"
    end
end
