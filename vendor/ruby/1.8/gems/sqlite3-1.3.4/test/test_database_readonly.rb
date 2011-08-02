require 'helper'

module SQLite3
  class TestDatabaseReadonly < Test::Unit::TestCase
    def setup
      File.unlink 'test-readonly.db' if File.exists?('test-readonly.db')
      @db = SQLite3::Database.new('test-readonly.db')
      @db.execute("CREATE TABLE foos (id integer)")
      @db.close
    end

    def teardown
      @db.close unless @db.closed?
      File.unlink 'test-readonly.db'
    end

    def test_open_readonly_database
      @db = SQLite3::Database.new('test-readonly.db', :readonly => true)
      assert @db.readonly?
    end

    def test_insert_readonly_database
      @db = SQLite3::Database.new('test-readonly.db', :readonly => true)
      assert_raise(SQLite3::ReadOnlyException) do
        @db.execute("INSERT INTO foos (id) VALUES (12)")
      end
    end
  end
end
