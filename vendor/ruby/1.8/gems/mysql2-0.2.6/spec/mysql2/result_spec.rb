# encoding: UTF-8
require 'spec_helper'

describe Mysql2::Result do
  before(:each) do
    @client = Mysql2::Client.new :host => "localhost", :username => "root"
  end

  before(:each) do
    @result = @client.query "SELECT 1"
  end

  it "should have included Enumerable" do
    Mysql2::Result.ancestors.include?(Enumerable).should be_true
  end

  it "should respond to #each" do
    @result.should respond_to(:each)
  end

  it "should raise a Mysql2::Error exception upon a bad query" do
    lambda {
      @client.query "bad sql"
    }.should raise_error(Mysql2::Error)

    lambda {
      @client.query "SELECT 1"
    }.should_not raise_error(Mysql2::Error)
  end

  context "#each" do
    it "should yield rows as hash's" do
      @result.each do |row|
        row.class.should eql(Hash)
      end
    end

    it "should yield rows as hash's with symbol keys if :symbolize_keys was set to true" do
      @result.each(:symbolize_keys => true) do |row|
        row.keys.first.class.should eql(Symbol)
      end
    end

    it "should be able to return results as an array" do
      @result.each(:as => :array) do |row|
        row.class.should eql(Array)
      end
    end

    it "should cache previously yielded results by default" do
      @result.first.object_id.should eql(@result.first.object_id)
    end

    it "should not cache previously yielded results if cache_rows is disabled" do
      result = @client.query "SELECT 1", :cache_rows => false
      result.first.object_id.should_not eql(result.first.object_id)
    end
  end

  context "#fields" do
    before(:each) do
      @client.query "USE test"
      @test_result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1")
    end

    it "method should exist" do
      @test_result.should respond_to(:fields)
    end

    it "should return an array of field names in proper order" do
      result = @client.query "SELECT 'a', 'b', 'c'"
      result.fields.should eql(['a', 'b', 'c'])
    end
  end

  context "row data type mapping" do
    before(:each) do
      @client.query "USE test"
      @test_result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
    end

    it "should return nil for a NULL value" do
      @test_result['null_test'].class.should eql(NilClass)
      @test_result['null_test'].should eql(nil)
    end

    it "should return Fixnum for a BIT value" do
      @test_result['bit_test'].class.should eql(String)
      @test_result['bit_test'].should eql("\000\000\000\000\000\000\000\005")
    end

    it "should return Fixnum for a TINYINT value" do
      [Fixnum, Bignum].should include(@test_result['tiny_int_test'].class)
      @test_result['tiny_int_test'].should eql(1)
    end

    it "should return TrueClass or FalseClass for a TINYINT value if :cast_booleans is enabled" do
      @client.query 'INSERT INTO mysql2_test (bool_cast_test) VALUES (1)'
      id1 = @client.last_id
      @client.query 'INSERT INTO mysql2_test (bool_cast_test) VALUES (0)'
      id2 = @client.last_id

      result1 = @client.query 'SELECT bool_cast_test FROM mysql2_test WHERE bool_cast_test = 1 LIMIT 1', :cast_booleans => true
      result2 = @client.query 'SELECT bool_cast_test FROM mysql2_test WHERE bool_cast_test = 0 LIMIT 1', :cast_booleans => true
      result1.first['bool_cast_test'].should be_true
      result2.first['bool_cast_test'].should be_false

      @client.query "DELETE from mysql2_test WHERE id IN(#{id1},#{id2})"
    end

    it "should return Fixnum for a SMALLINT value" do
      [Fixnum, Bignum].should include(@test_result['small_int_test'].class)
      @test_result['small_int_test'].should eql(10)
    end

    it "should return Fixnum for a MEDIUMINT value" do
      [Fixnum, Bignum].should include(@test_result['medium_int_test'].class)
      @test_result['medium_int_test'].should eql(10)
    end

    it "should return Fixnum for an INT value" do
      [Fixnum, Bignum].should include(@test_result['int_test'].class)
      @test_result['int_test'].should eql(10)
    end

    it "should return Fixnum for a BIGINT value" do
      [Fixnum, Bignum].should include(@test_result['big_int_test'].class)
      @test_result['big_int_test'].should eql(10)
    end

    it "should return Fixnum for a YEAR value" do
      [Fixnum, Bignum].should include(@test_result['year_test'].class)
      @test_result['year_test'].should eql(2009)
    end

    it "should return BigDecimal for a DECIMAL value" do
      @test_result['decimal_test'].class.should eql(BigDecimal)
      @test_result['decimal_test'].should eql(10.3)
    end

    it "should return Float for a FLOAT value" do
      @test_result['float_test'].class.should eql(Float)
      @test_result['float_test'].should eql(10.3)
    end

    it "should return Float for a DOUBLE value" do
      @test_result['double_test'].class.should eql(Float)
      @test_result['double_test'].should eql(10.3)
    end

    it "should return Time for a DATETIME value when within the supported range" do
      @test_result['date_time_test'].class.should eql(Time)
      @test_result['date_time_test'].strftime("%F %T").should eql('2010-04-04 11:44:00')
    end

    it "should return DateTime for a DATETIME value when outside the supported range" do
      r = @client.query("SELECT CAST('1901-1-1 01:01:01' AS DATETIME) as test")
      r.first['test'].class.should eql(DateTime)
    end

    it "should return Time for a TIMESTAMP value when within the supported range" do
      @test_result['timestamp_test'].class.should eql(Time)
      @test_result['timestamp_test'].strftime("%F %T").should eql('2010-04-04 11:44:00')
    end

    it "should return Time for a TIME value" do
      @test_result['time_test'].class.should eql(Time)
      @test_result['time_test'].strftime("%F %T").should eql('2000-01-01 11:44:00')
    end

    it "should return Date for a DATE value" do
      @test_result['date_test'].class.should eql(Date)
      @test_result['date_test'].strftime("%F").should eql('2010-04-04')
    end

    it "should return String for an ENUM value" do
      @test_result['enum_test'].class.should eql(String)
      @test_result['enum_test'].should eql('val1')
    end

    if defined? Encoding
      context "string encoding for ENUM values" do
        it "should default to the connection's encoding if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['enum_test'].encoding.should eql(Encoding.find('utf-8'))

          client2 = Mysql2::Client.new :encoding => 'ascii'
          client2.query "USE test"
          result = client2.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['enum_test'].encoding.should eql(Encoding.find('us-ascii'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['enum_test'].encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['enum_test'].encoding.should eql(Encoding.default_internal)
        end
      end
    end

    it "should return String for a SET value" do
      @test_result['set_test'].class.should eql(String)
      @test_result['set_test'].should eql('val1,val2')
    end

    if defined? Encoding
      context "string encoding for SET values" do
        it "should default to the connection's encoding if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['set_test'].encoding.should eql(Encoding.find('utf-8'))

          client2 = Mysql2::Client.new :encoding => 'ascii'
          client2.query "USE test"
          result = client2.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['set_test'].encoding.should eql(Encoding.find('us-ascii'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['set_test'].encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['set_test'].encoding.should eql(Encoding.default_internal)
        end
      end
    end

    it "should return String for a BINARY value" do
      @test_result['binary_test'].class.should eql(String)
      @test_result['binary_test'].should eql("test#{"\000"*6}")
    end

    if defined? Encoding
      context "string encoding for BINARY values" do
        it "should default to binary if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['binary_test'].encoding.should eql(Encoding.find('binary'))
        end

        it "should not use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['binary_test'].encoding.should eql(Encoding.find('binary'))
          Encoding.default_internal = Encoding.find('us-ascii')
          result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
          result['binary_test'].encoding.should eql(Encoding.find('binary'))
        end
      end
    end

    {
      'char_test' => 'CHAR',
      'varchar_test' => 'VARCHAR',
      'varbinary_test' => 'VARBINARY',
      'tiny_blob_test' => 'TINYBLOB',
      'tiny_text_test' => 'TINYTEXT',
      'blob_test' => 'BLOB',
      'text_test' => 'TEXT',
      'medium_blob_test' => 'MEDIUMBLOB',
      'medium_text_test' => 'MEDIUMTEXT',
      'long_blob_test' => 'LONGBLOB',
      'long_text_test' => 'LONGTEXT'
    }.each do |field, type|
      it "should return a String for #{type}" do
        @test_result[field].class.should eql(String)
        @test_result[field].should eql("test")
      end

      if defined? Encoding
        context "string encoding for #{type} values" do
          if ['VARBINARY', 'TINYBLOB', 'BLOB', 'MEDIUMBLOB', 'LONGBLOB'].include?(type)
            it "should default to binary if Encoding.default_internal is nil" do
              Encoding.default_internal = nil
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result['binary_test'].encoding.should eql(Encoding.find('binary'))
            end

            it "should not use Encoding.default_internal" do
              Encoding.default_internal = Encoding.find('utf-8')
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result['binary_test'].encoding.should eql(Encoding.find('binary'))
              Encoding.default_internal = Encoding.find('us-ascii')
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result['binary_test'].encoding.should eql(Encoding.find('binary'))
            end
          else
            it "should default to utf-8 if Encoding.default_internal is nil" do
              Encoding.default_internal = nil
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result[field].encoding.should eql(Encoding.find('utf-8'))

              client2 = Mysql2::Client.new :encoding => 'ascii'
              client2.query "USE test"
              result = client2.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result[field].encoding.should eql(Encoding.find('us-ascii'))
            end

            it "should use Encoding.default_internal" do
              Encoding.default_internal = Encoding.find('utf-8')
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result[field].encoding.should eql(Encoding.default_internal)
              Encoding.default_internal = Encoding.find('us-ascii')
              result = @client.query("SELECT * FROM mysql2_test ORDER BY id DESC LIMIT 1").first
              result[field].encoding.should eql(Encoding.default_internal)
            end
          end
        end
      end
    end
  end
end
