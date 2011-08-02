# -*- coding: utf-8 -*-

require 'helper'

module SQLite3
  class TestEncoding < Test::Unit::TestCase
    def setup
      @db = SQLite3::Database.new(':memory:')
      @create = "create table ex(id int, data string)"
      @insert = "insert into ex(id, data) values (?, ?)"
      @db.execute(@create);
    end

    def test_default_internal_is_honored
      warn_before = $-w
      $-w = false

      before_enc = Encoding.default_internal

      str = "壁に耳あり、障子に目あり"
      stmt = @db.prepare('insert into ex(data) values (?)')
      stmt.bind_param 1, str
      stmt.step

      Encoding.default_internal = 'EUC-JP'
      string = @db.execute('select data from ex').first.first

      assert_equal Encoding.default_internal, string.encoding
      assert_equal str.encode('EUC-JP'), string
      assert_equal str, string.encode(str.encoding)
    ensure
      Encoding.default_internal = before_enc
      $-w = warn_before
    end

    def test_blob_is_binary
      str = "猫舌"
      @db.execute('create table foo(data text)')
      stmt = @db.prepare('insert into foo(data) values (?)')
      stmt.bind_param(1, SQLite3::Blob.new(str))
      stmt.step

      string = @db.execute('select data from foo').first.first
      assert_equal Encoding.find('ASCII-8BIT'), string.encoding
      assert_equal str, string.force_encoding('UTF-8')
    end

    def test_blob_is_ascii8bit
      str = "猫舌"
      @db.execute('create table foo(data text)')
      stmt = @db.prepare('insert into foo(data) values (?)')
      stmt.bind_param(1, str.dup.force_encoding("ASCII-8BIT"))
      stmt.step

      string = @db.execute('select data from foo').first.first
      assert_equal Encoding.find('ASCII-8BIT'), string.encoding
      assert_equal str, string.force_encoding('UTF-8')
    end

    def test_blob_with_eucjp
      str = "猫舌".encode("EUC-JP")
      @db.execute('create table foo(data text)')
      stmt = @db.prepare('insert into foo(data) values (?)')
      stmt.bind_param(1, SQLite3::Blob.new(str))
      stmt.step

      string = @db.execute('select data from foo').first.first
      assert_equal Encoding.find('ASCII-8BIT'), string.encoding
      assert_equal str, string.force_encoding('EUC-JP')
    end

    def test_db_with_eucjp
      db = SQLite3::Database.new(':memory:'.encode('EUC-JP'))
      assert_equal(Encoding.find('UTF-8'), db.encoding)
    end

    def test_db_with_utf16
      db = SQLite3::Database.new(':memory:'.encode('UTF-16LE'))
      assert_equal(Encoding.find('UTF-16LE'), db.encoding)
    end

    def test_statement_eucjp
      str = "猫舌"
      @db.execute("insert into ex(data) values ('#{str}')".encode('EUC-JP'))
      row = @db.execute("select data from ex")
      assert_equal @db.encoding, row.first.first.encoding
      assert_equal str, row.first.first
    end

    def test_statement_utf8
      str = "猫舌"
      @db.execute("insert into ex(data) values ('#{str}')")
      row = @db.execute("select data from ex")
      assert_equal @db.encoding, row.first.first.encoding
      assert_equal str, row.first.first
    end

    def test_encoding
      assert_equal Encoding.find("UTF-8"), @db.encoding
    end

    def test_utf_8
      str = "猫舌"
      @db.execute(@insert, [10, str])
      row = @db.execute("select data from ex")
      assert_equal @db.encoding, row.first.first.encoding
      assert_equal str, row.first.first
    end

    def test_euc_jp
      str = "猫舌".encode('EUC-JP')
      @db.execute(@insert, [10, str])
      row = @db.execute("select data from ex")
      assert_equal @db.encoding, row.first.first.encoding
      assert_equal str.encode('UTF-8'), row.first.first
    end

  end if RUBY_VERSION >= '1.9.1'
end
