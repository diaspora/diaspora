require './test/test_helper'
include Mongo

class GridFileSystemTest < Test::Unit::TestCase
  context "GridFileSystem:" do
    setup do
      @con = Connection.new(ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
        ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT)
      @db = @con.db(MONGO_TEST_DB)
    end

    teardown do
      @db['fs.files'].remove
      @db['fs.chunks'].remove
    end

    context "When reading:" do
      setup do
        @chunks_data = "CHUNKS" * 50000
        @grid = GridFileSystem.new(@db)
        @grid.open('sample.file', 'w') do |f|
          f.write @chunks_data
        end

        @grid = GridFileSystem.new(@db)
      end

      should "return existence of the file" do
        file = @grid.exist?(:filename => 'sample.file')
        assert_equal 'sample.file', file['filename']
      end

      should "return nil if the file doesn't exist" do
        assert_nil @grid.exist?(:filename => 'foo.file')
      end

      should "read sample data" do
        data = @grid.open('sample.file', 'r') { |f| f.read }
        assert_equal data.length, @chunks_data.length
      end

      should "have a unique index on chunks" do
        assert @db['fs.chunks'].index_information['files_id_1_n_1']['unique']
      end

      should "have an index on filename" do
        assert @db['fs.files'].index_information['filename_1_uploadDate_-1']
      end

      should "return an empty string if length is zero" do
        data = @grid.open('sample.file', 'r') { |f| f.read(0) }
        assert_equal '', data
      end

      should "return the first n bytes" do
        data = @grid.open('sample.file', 'r') {|f| f.read(288888) }
        assert_equal 288888, data.length
        assert_equal @chunks_data[0...288888], data
      end

      should "return the first n bytes even with an offset" do
        data = @grid.open('sample.file', 'r') do |f| 
          f.seek(1000)
          f.read(288888)
        end
        assert_equal 288888, data.length
        assert_equal @chunks_data[1000...289888], data
      end
    end

    context "When writing:" do
     setup do
       @data   = "BYTES" * 50
       @grid = GridFileSystem.new(@db)
       @grid.open('sample', 'w') do |f|
         f.write @data
       end
     end

     should "read sample data" do
       data = @grid.open('sample', 'r') { |f| f.read }
       assert_equal data.length, @data.length
     end

     should "return the total number of bytes written" do
       data = 'a' * 300000
       assert_equal 300000, @grid.open('sample', 'w') {|f| f.write(data) }
     end

     should "more read sample data" do
       data = @grid.open('sample', 'r') { |f| f.read }
       assert_equal data.length, @data.length
     end

     should "raise exception if file not found" do
       assert_raise GridFileNotFound do
         @grid.open('io', 'r') { |f| f.write('hello') }
       end
     end

     should "raise exception if not opened for write" do
       assert_raise GridError do
         @grid.open('sample', 'r') { |f| f.write('hello') }
       end
     end

     context "and when overwriting the file" do
       setup do
         @old = @grid.open('sample', 'r')

         @new_data = "DATA" * 10
         sleep(2)
         @grid.open('sample', 'w') do |f|
           f.write @new_data
         end

         @new = @grid.open('sample', 'r')
       end

       should "have a newer upload date" do
         assert @new.upload_date > @old.upload_date, "New data is not greater than old date."
       end

       should "have a different files_id" do
         assert_not_equal @new.files_id, @old.files_id
       end

       should "contain the new data" do
         assert_equal @new_data, @new.read, "Expected DATA"
       end

       context "and on a second overwrite" do
         setup do
           sleep(2)
           @new_data = "NEW" * 1000
           @grid.open('sample', 'w') do |f|
             f.write @new_data
           end

           @ids = @db['fs.files'].find({'filename' => 'sample'}).map {|file| file['_id']}
         end

         should "write a third version of the file" do
           assert_equal 3, @db['fs.files'].find({'filename' => 'sample'}).count
           assert_equal 3, @db['fs.chunks'].find({'files_id' => {'$in' => @ids}}).count
         end

         should "remove all versions and their data on delete" do
           @grid.delete('sample')
           assert_equal 0, @db['fs.files'].find({'filename' => 'sample'}).count
           assert_equal 0, @db['fs.chunks'].find({'files_id' => {'$in' => @ids}}).count
         end

         should "delete old versions on write with :delete_old is passed in" do
           @grid.open('sample', 'w', :delete_old => true) do |f|
             f.write @new_data
           end
           @new_ids = @db['fs.files'].find({'filename' => 'sample'}).map {|file| file['_id']}
           assert_equal 1, @new_ids.length
           id = @new_ids.first
           assert !@ids.include?(id)
           assert_equal 1, @db['fs.files'].find({'filename' => 'sample'}).count
           assert_equal 1, @db['fs.chunks'].find({'files_id' => id}).count
         end
       end
     end
   end

   context "When writing chunks:" do
      setup do
        data   = "B" * 50000
        @grid = GridFileSystem.new(@db)
        @grid.open('sample', 'w', :chunk_size => 1000) do |f|
          f.write data
        end
      end

      should "write the correct number of chunks" do
        file   = @db['fs.files'].find_one({:filename => 'sample'})
        chunks = @db['fs.chunks'].find({'files_id' => file['_id']}).to_a
        assert_equal 50, chunks.length
      end
    end

    context "Positioning:" do
      setup do
        data = 'hello, world' + '1' * 5000 + 'goodbye!' + '2' * 1000 + '!'
        @grid = GridFileSystem.new(@db)
        @grid.open('hello', 'w', :chunk_size => 1000) do |f|
          f.write data
        end
      end

      should "seek within chunks" do
        @grid.open('hello', 'r') do |f|
          f.seek(0)
          assert_equal 'h', f.read(1)
          f.seek(7)
          assert_equal 'w', f.read(1)
          f.seek(4)
          assert_equal 'o', f.read(1)
          f.seek(0)
          f.seek(7, IO::SEEK_CUR)
          assert_equal 'w', f.read(1)
          f.seek(-2, IO::SEEK_CUR)
          assert_equal ' ', f.read(1)
          f.seek(-4, IO::SEEK_CUR)
          assert_equal 'l', f.read(1)
          f.seek(3, IO::SEEK_CUR)
          assert_equal 'w', f.read(1)
        end
      end

      should "seek between chunks" do
        @grid.open('hello', 'r') do |f|
          f.seek(1000)
          assert_equal '11111', f.read(5)

          f.seek(5009)
          assert_equal '111goodbye!222', f.read(14)

          f.seek(-1, IO::SEEK_END)
          assert_equal '!', f.read(1)
          f.seek(-6, IO::SEEK_END)
          assert_equal '2', f.read(1)
        end
      end

      should "tell the current position" do
        @grid.open('hello', 'r') do |f|
          assert_equal 0, f.tell

          f.seek(999)
          assert_equal 999, f.tell
        end
      end

      should "seek only in read mode" do
        assert_raise GridError do
          @grid.open('hello', 'w') {|f| f.seek(0) }
        end
      end
    end
  end
end
