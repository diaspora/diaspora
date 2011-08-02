require 'delegate'

begin
    require 'rubygems'
    gem 'deprecated', "= 2.0.1"
rescue LoadError => e
end

require 'deprecated'

module DBI
    # This represents metadata for columns within a given table, such as the
    # data type, whether or not the the column is a primary key, etc.
    #
    # ColumnInfo is a delegate of Hash, but represents its keys indifferently,
    # coercing all strings to symbols. It also has ostruct-like features, f.e.:
    #
    #   h = ColumnInfo.new({ "foo" => "bar" })
    #   h[:foo] => "bar"
    #   h["foo"] => "bar"
    #   h.foo => "bar"
    #
    # All of these forms have assignment forms as well.
    #
    class ColumnInfo < DelegateClass(Hash)

        # Create a new ColumnInfo object.
        #
        # If no Hash is provided, one will be created for you. The hash will be
        # shallow cloned for storage inside the object, and an attempt will be
        # made to convert all string keys to symbols.
        #
        # In the event that both string and symbol keys are provided in the
        # initial hash, we cannot safely route around collisions and therefore
        # a TypeError is raised.
        #
        def initialize(hash=nil)
            @hash = hash.dup rescue nil
            @hash ||= Hash.new

            # coerce all strings to symbols
            @hash.each_key do |x|
                if x.kind_of? String
                    sym = x.to_sym
                    if @hash.has_key? sym
                        raise ::TypeError, 
                            "#{self.class.name} may construct from a hash keyed with strings or symbols, but not both" 
                    end
                    @hash[sym] = @hash[x]
                    @hash.delete(x)
                end
            end

            super(@hash)
        end

        def [](key)
            @hash[key.to_sym]
        end

        def []=(key, value)
            @hash[key.to_sym] = value
        end

        def default() # :nodoc; XXX hack to get around Hash#default
            method_missing(:default)
        end

        def method_missing(sym, value=nil)
            if sym.to_s =~ /=$/
                sym = sym.to_s.sub(/=$/, '').to_sym
                @hash[sym] = value
            elsif sym.to_s =~ /\?$/
                sym = sym.to_s.sub(/\?$/, '').to_sym
                @hash[sym]
            else
                @hash[sym]
            end
        end

        # Aliases - XXX soon to be deprecated
        def self.deprecated_alias(target, source) # :nodoc:
            define_method(target) { |*args| method_missing(source, *args) }
            deprecate target 
        end

        deprecated_alias :is_nullable?, :nullable
        deprecated_alias :can_be_null?, :nullable

        deprecated_alias :is_indexed?, :indexed

        deprecated_alias :is_primary?, :primary

        deprecated_alias :is_unique, :unique

        deprecated_alias :size, :precision
        deprecated_alias :size=, :precision=
        deprecated_alias :length, :precision
        deprecated_alias :length=, :precision=

        deprecated_alias :decimal_digits, :scale
        deprecated_alias :decimal_digits=, :scale=

        deprecated_alias :default_value, :default
        deprecated_alias :default_value=, :default=
    end
end
