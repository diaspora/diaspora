$LOAD_PATH.unshift(Dir.pwd)
$LOAD_PATH.unshift(File.dirname(Dir.pwd))
$LOAD_PATH.unshift("../../lib")
$LOAD_PATH.unshift("../../lib/dbi")
$LOAD_PATH.unshift("lib")

require "dbi"
require "test/unit"

class MyType
    def initialize(obj)
        @obj = obj
    end

    def to_s
        @obj.to_s
    end
end

class TC_DBI_Type < Test::Unit::TestCase
    def test_null
        # all types except Varchar need to appropriately handle NULL
        [
            DBI::Type::Null,
            DBI::Type::Integer,
            DBI::Type::Float,
            DBI::Type::Timestamp,
            DBI::Type::Boolean
        ].each do |klass|
            assert_equal(nil, klass.parse("NULL"))
            assert_equal(nil, klass.parse("null"))
            assert_equal(nil, klass.parse("Null"))
        end
    end

    def test_boolean
        klass = DBI::Type::Boolean
        assert_kind_of(NilClass, klass.parse(nil))
        assert_kind_of(NilClass, klass.parse("NULL"))
        assert_kind_of(TrueClass, klass.parse('t'))
        assert_kind_of(TrueClass, klass.parse(1))
        assert_kind_of(TrueClass, klass.parse('1'))
        assert_kind_of(FalseClass, klass.parse('f'))
        assert_kind_of(FalseClass, klass.parse(0))
        assert_kind_of(FalseClass, klass.parse('0'))
    end

    def test_varchar
        klass = DBI::Type::Varchar
        assert_kind_of(String, klass.parse("hello"))
        assert_kind_of(String, klass.parse("1"))
        assert_kind_of(String, klass.parse("1.23"))

        assert_equal("NULL", klass.parse("NULL"))
        assert_equal("1", klass.parse("1"))
        assert_equal("hello", klass.parse("hello"))
        assert_equal("1.23", klass.parse("1.23"))
    end

    def test_integer
        klass = DBI::Type::Integer
        assert_kind_of(Integer, klass.parse("1.23"))
        assert_kind_of(Integer, klass.parse("-1.23"))
        assert_kind_of(Integer, klass.parse("1.0"))
        assert_kind_of(Integer, klass.parse("1"))
        assert_kind_of(Integer, klass.parse("-1"))
        assert_kind_of(Integer, klass.parse("0"))

        assert_equal(nil, klass.parse("NULL"))
        assert_equal(1, klass.parse("1.23"))
        assert_equal(-1, klass.parse("-1.23"))
        assert_equal(1, klass.parse("1.0"))
        assert_equal(1, klass.parse("1"))
        assert_equal(-1, klass.parse("-1"))
        assert_equal(0, klass.parse("0"))
    end

    def test_float
        klass = DBI::Type::Float
        assert_kind_of(Float, klass.parse("1.23"))
        assert_kind_of(Float, klass.parse("-1.23"))
        assert_kind_of(Float, klass.parse("1.0"))
        assert_kind_of(Float, klass.parse("1"))
        assert_kind_of(Float, klass.parse("-1"))
        assert_kind_of(Float, klass.parse("0"))

        assert_equal(nil, klass.parse("NULL"))
        assert_equal(1.23, klass.parse("1.23"))
        assert_equal(-1.23, klass.parse("-1.23"))
        assert_equal(1, klass.parse("1.0"))
        assert_equal(1, klass.parse("1"))
        assert_equal(-1, klass.parse("-1"))
        assert_equal(0, klass.parse("0"))
    end

    def test_timestamp
        klass = DBI::Type::Timestamp
        assert_kind_of(DateTime, klass.parse(Time.now))
        assert_kind_of(DateTime, klass.parse(Date.today))
        assert_kind_of(DateTime, klass.parse(DateTime.now))
        assert_kind_of(DateTime, klass.parse(Time.now.to_s))
        assert_kind_of(DateTime, klass.parse(Date.today.to_s))
        assert_kind_of(DateTime, klass.parse(DateTime.now.to_s))

        assert_equal(nil, klass.parse("NULL"))

        # string coercion
        dt = DateTime.now
        assert_equal(dt.to_s, klass.parse(dt).to_s)
        
        t = Time.now
        assert_equal(DateTime.parse(t.to_s).to_s, klass.parse(t).to_s)

        d = Date.today
        assert_equal(DateTime.parse(d.to_s).to_s, klass.parse(d).to_s)

        md = "10-11"

        if RUBY_VERSION =~ /^1\.9/
            md = "11-10"
        end

        # be sure we're actually getting the right data back
        assert_equal(
            "2008-#{md}",
            klass.parse(Date.parse("10/11/2008")).strftime("%Y-%m-%d")
        )

        assert_equal(
            "10:01:02",
            klass.parse(Time.parse("10:01:02")).strftime("%H:%M:%S")
        )

        assert_equal(
            "#{md}-2008 10:01:02",
            klass.parse(DateTime.parse("10/11/2008 10:01:02")).strftime("%m-%d-%Y %H:%M:%S")
        )

        # precision tests, related to ticket #27182
      
        # iso8601 (bypasses regex)
        [
            '2009-09-27T19:41:00-05:00',
            '2009-09-27T19:41:00.123-05:00'
        ].each do |string|
            assert_equal(DateTime.parse(string), klass.parse(string))
        end

        # offset comparison check
        assert_equal(
            DateTime.parse('2009-09-27T19:41:00.123-05:00'),
            klass.parse('2009-09-28T00:41:00.123+00:00')
        )

        assert_equal(
            DateTime.parse('2009-09-28T00:41:00.123+00:00'),
            klass.parse('2009-09-27T19:41:00.123-05:00')
        )

        # unix convention (uses regex)
        
        [
            '2009-09-27 19:41:00 -05:00',
            '2009-09-27 19:41:00.123 -05:00'
        ].each do |string|
            assert_equal(DateTime.parse(string), klass.parse(string))
        end

        # offset comparison check
        assert_equal(
            DateTime.parse('2009-09-27 19:41:00.123 -05:00'),
            klass.parse('2009-09-28 00:41:00.123 +00:00')
        )

        assert_equal(
            DateTime.parse('2009-09-28 00:41:00.123 +00:00'),
            klass.parse('2009-09-27 19:41:00.123 -05:00')
        )
    end
end

class TC_DBI_TypeUtil < Test::Unit::TestCase
    def cast(obj)
        DBI::TypeUtil.convert(nil, obj)
    end

    def datecast(obj)
        "'#{::DateTime.parse(obj.to_s).strftime("%Y-%m-%dT%H:%M:%S")}'"
    end

    def test_default_unknown_cast
        assert_kind_of(String, cast(MyType.new("foo")))
        assert_equal("'foo'", cast(MyType.new("foo")))
    end

    def test_default_numeric_cast
        assert_kind_of(String, cast(1))
        assert_equal("1", cast(1))
    end

    def test_default_string_cast
        assert_kind_of(String, cast("foo"))
        assert_equal("'foo'", cast("foo"))
        assert_equal("'foo''bar'", cast("foo'bar"))
    end

    def test_default_time_casts
        assert_kind_of(String, cast(Time.now))
        assert_kind_of(String, cast(Date.today))
        assert_kind_of(String, cast(DateTime.now))
      
        obj = Time.now
        assert_equal(datecast(obj), cast(obj))
        obj = Date.today
        assert_equal(datecast(obj), cast(obj))
        obj = DateTime.now
        assert_equal(datecast(obj), cast(obj))
    end

    def test_default_boolean_casts
        assert_kind_of(String, cast(false))
        assert_kind_of(String, cast(true))
        assert_kind_of(NilClass, cast(nil))

        assert_equal("'1'", cast(true))
        assert_equal("'0'", cast(false))
        assert_equal(nil, cast(nil))
    end

    def test_default_binary_casts
        assert_kind_of(DBI::Binary, cast(DBI::Binary.new("poop")))
        obj = DBI::Binary.new("poop")
        assert_equal(obj.object_id, cast(obj).object_id)
    end
end

DBI::TypeUtil.register_conversion("test") do |obj|
    case obj
    when ::NilClass
        ["Custom Nil", false]
    when ::TrueClass
        ["Custom True", false]
    when ::FalseClass
        ["Custom False", false]
    else
        [obj, true]
    end
end

class TC_DBI_TypeUtil_Custom < Test::Unit::TestCase
    def cast(obj)
        DBI::TypeUtil.convert("test", obj)
    end

    def test_custom_casts
        assert_equal("Custom Nil", cast(nil))
        assert_equal("Custom True", cast(true))
        assert_equal("Custom False", cast(false))
    end

    def test_custom_fallthrough
        assert_equal("'foo'", cast(:foo))
        assert_equal("'foo'", cast("foo"))
        assert_equal("'foo''bar'", cast("foo'bar"))
        assert_equal("1", cast(1))
        assert_equal("'foo'", cast(MyType.new("foo")))
    end
end
