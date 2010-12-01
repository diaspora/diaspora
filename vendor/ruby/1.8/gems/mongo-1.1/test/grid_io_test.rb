require './test/test_helper'
include Mongo

class GridIOTest < Test::Unit::TestCase

  context "GridIO" do
    setup do
      @db ||= Connection.new(ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
        ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT).db(MONGO_TEST_DB)
      @files  = @db.collection('fs.files')
      @chunks = @db.collection('fs.chunks')
      @chunks.create_index([['files_id', Mongo::ASCENDING], ['n', Mongo::ASCENDING]])
    end

    teardown do
      @files.remove
      @chunks.remove
    end

    context "Options" do
      setup do
        @filename = 'test'
        @mode     = 'w'
      end

      should "set default 256k chunk size" do
        file = GridIO.new(@files, @chunks, @filename, @mode)
        assert_equal 256 * 1024, file.chunk_size
      end

      should "set chunk size" do
        file = GridIO.new(@files, @chunks, @filename, @mode, :chunk_size => 1000)
        assert_equal 1000, file.chunk_size
      end
    end

    context "Grid MD5 check" do
      should "run in safe mode" do
        file = GridIO.new(@files, @chunks, 'smallfile', 'w', :safe => true)
        file.write("DATA" * 100)
        assert file.close
        assert_equal file.server_md5, file.client_md5
      end

      should "validate with a large file" do
        io = File.open(File.join(File.dirname(__FILE__), 'data', 'sample_file.pdf'), 'r')
        file = GridIO.new(@files, @chunks, 'bigfile', 'w', :safe => true)
        file.write(io)
        assert file.close
        assert_equal file.server_md5, file.client_md5
      end

      should "raise an exception when check fails" do
        io = File.open(File.join(File.dirname(__FILE__), 'data', 'sample_file.pdf'), 'r')
        @db.stubs(:command).returns({'md5' => '12345'})
        file = GridIO.new(@files, @chunks, 'bigfile', 'w', :safe => true)
        file.write(io)
        assert_raise GridMD5Failure do
          assert file.close
        end
        assert_not_equal file.server_md5, file.client_md5
      end
    end

    context "Content types" do

      if defined?(MIME)
        should "determine common content types from the extension" do
          file = GridIO.new(@files, @chunks, 'sample.pdf', 'w')
          assert_equal 'application/pdf', file.content_type

          file = GridIO.new(@files, @chunks, 'sample.txt', 'w')
          assert_equal 'text/plain', file.content_type
        end
      end

      should "default to binary/octet-stream when type is unknown" do
        file = GridIO.new(@files, @chunks, 'sample.l33t', 'w')
        assert_equal 'binary/octet-stream', file.content_type
      end

      should "use any provided content type by default" do
        file = GridIO.new(@files, @chunks, 'sample.l33t', 'w', :content_type => 'image/jpg')
        assert_equal 'image/jpg', file.content_type
      end
    end
  end

end
