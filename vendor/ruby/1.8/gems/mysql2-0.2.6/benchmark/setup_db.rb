# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

# This script is for generating psudo-random data into a single table consisting of nearly every
# data type MySQL 5.1 supports.
#
# It's meant to be used with the query.rb benchmark script (or others in the future)

require 'mysql2'
require 'rubygems'
require 'faker'

num = ENV['NUM'] && ENV['NUM'].to_i || 10_000

create_table_sql = %[
  CREATE TABLE IF NOT EXISTS mysql2_test (
    null_test VARCHAR(10),
    bit_test BIT,
    tiny_int_test TINYINT,
    small_int_test SMALLINT,
    medium_int_test MEDIUMINT,
    int_test INT,
    big_int_test BIGINT,
    float_test FLOAT(10,3),
    float_zero_test FLOAT(10,3),
    double_test DOUBLE(10,3),
    decimal_test DECIMAL(10,3),
    decimal_zero_test DECIMAL(10,3),
    date_test DATE,
    date_time_test DATETIME,
    timestamp_test TIMESTAMP,
    time_test TIME,
    year_test YEAR(4),
    char_test CHAR(10),
    varchar_test VARCHAR(10),
    binary_test BINARY(10),
    varbinary_test VARBINARY(10),
    tiny_blob_test TINYBLOB,
    tiny_text_test TINYTEXT,
    blob_test BLOB,
    text_test TEXT,
    medium_blob_test MEDIUMBLOB,
    medium_text_test MEDIUMTEXT,
    long_blob_test LONGBLOB,
    long_text_test LONGTEXT,
    enum_test ENUM('val1', 'val2'),
    set_test SET('val1', 'val2')
  ) DEFAULT CHARSET=utf8
]

# connect to localhost by default, pass options as needed
@client = Mysql2::Client.new :host => "localhost", :username => "root", :database => "test"

@client.query create_table_sql

def insert_record(args)
  insert_sql = "
    INSERT INTO mysql2_test (
      null_test, bit_test, tiny_int_test, small_int_test, medium_int_test, int_test, big_int_test,
      float_test, float_zero_test, double_test, decimal_test, decimal_zero_test, date_test, date_time_test, timestamp_test, time_test,
      year_test, char_test, varchar_test, binary_test, varbinary_test, tiny_blob_test,
      tiny_text_test, blob_test, text_test, medium_blob_test, medium_text_test,
      long_blob_test, long_text_test, enum_test, set_test
    )

    VALUES (
      NULL, #{args[:bit_test]}, #{args[:tiny_int_test]}, #{args[:small_int_test]}, #{args[:medium_int_test]}, #{args[:int_test]}, #{args[:big_int_test]},
      #{args[:float_test]}, #{args[:float_zero_test]}, #{args[:double_test]}, #{args[:decimal_test]}, #{args[:decimal_zero_test]}, '#{args[:date_test]}', '#{args[:date_time_test]}', '#{args[:timestamp_test]}', '#{args[:time_test]}',
      #{args[:year_test]}, '#{args[:char_test]}', '#{args[:varchar_test]}', '#{args[:binary_test]}', '#{args[:varbinary_test]}', '#{args[:tiny_blob_test]}',
      '#{args[:tiny_text_test]}', '#{args[:blob_test]}', '#{args[:text_test]}', '#{args[:medium_blob_test]}', '#{args[:medium_text_test]}',
      '#{args[:long_blob_test]}', '#{args[:long_text_test]}', '#{args[:enum_test]}', '#{args[:set_test]}'
    )
  "
  @client.query insert_sql
end

puts "Creating #{num} records"
num.times do |n|
  insert_record(
    :bit_test => 1,
    :tiny_int_test => rand(128),
    :small_int_test => rand(32767),
    :medium_int_test => rand(8388607),
    :int_test => rand(2147483647),
    :big_int_test => rand(9223372036854775807),
    :float_test => rand(32767)/1.87,
    :float_zero_test => 0.0,
    :double_test => rand(8388607)/1.87,
    :decimal_test => rand(8388607)/1.87,
    :decimal_zero_test => 0,
    :date_test => '2010-4-4',
    :date_time_test => '2010-4-4 11:44:00',
    :timestamp_test => '2010-4-4 11:44:00',
    :time_test => '11:44:00',
    :year_test => Time.now.year,
    :char_test => Faker::Lorem.words(rand(5)),
    :varchar_test => Faker::Lorem.words(rand(5)),
    :binary_test => Faker::Lorem.words(rand(5)),
    :varbinary_test => Faker::Lorem.words(rand(5)),
    :tiny_blob_test => Faker::Lorem.words(rand(5)),
    :tiny_text_test => Faker::Lorem.paragraph(rand(5)),
    :blob_test => Faker::Lorem.paragraphs(rand(25)),
    :text_test => Faker::Lorem.paragraphs(rand(25)),
    :medium_blob_test => Faker::Lorem.paragraphs(rand(25)),
    :medium_text_test => Faker::Lorem.paragraphs(rand(25)),
    :long_blob_test => Faker::Lorem.paragraphs(rand(25)),
    :long_text_test => Faker::Lorem.paragraphs(rand(25)),
    :enum_test => ['val1', 'val2'].rand,
    :set_test => ['val1', 'val2', 'val1,val2'].rand
  )
  $stdout.putc '.'
  $stdout.flush
end
puts
puts "Done"