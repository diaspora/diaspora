require 'helper'

module SQLite3
  class TestSQLite3 < Test::Unit::TestCase
    def test_libversion
      assert_not_nil SQLite3.libversion
    end
  end
end
