require "common"

class UploadTest < Net::SFTP::TestCase
  def setup
    prepare_progress!
  end

  def test_upload_file_should_send_file_contents
    expect_file_transfer("/path/to/local", "/path/to/remote", "here are the contents")
    assert_scripted_command { sftp.upload("/path/to/local", "/path/to/remote") }
  end

  def test_upload_file_with_progress_should_report_progress
    expect_file_transfer("/path/to/local", "/path/to/remote", "here are the contents")

    assert_scripted_command do
      sftp.upload("/path/to/local", "/path/to/remote") { |*args| record_progress(args) }
    end

    assert_progress_reported_open(:remote => "/path/to/remote")
    assert_progress_reported_put(0, "here are the contents", :remote => "/path/to/remote")
    assert_progress_reported_close(:remote => "/path/to/remote")
    assert_progress_reported_finish
    assert_no_more_reported_events
  end

  def test_upload_file_with_progress_handler_should_report_progress
    expect_file_transfer("/path/to/local", "/path/to/remote", "here are the contents")

    assert_scripted_command do
      sftp.upload("/path/to/local", "/path/to/remote", :progress => ProgressHandler.new(@progress))
    end

    assert_progress_reported_open(:remote => "/path/to/remote")
    assert_progress_reported_put(0, "here are the contents", :remote => "/path/to/remote")
    assert_progress_reported_close(:remote => "/path/to/remote")
    assert_progress_reported_finish
    assert_no_more_reported_events
  end

  def test_upload_file_should_read_chunks_of_size(requested_size=nil)
    size = requested_size || Net::SFTP::Operations::Upload::DEFAULT_READ_SIZE
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_OPEN, :long, 0, :string, "/path/to/remote", :long, 0x1A, :long, 0)
      channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
      channel.sends_packet(FXP_WRITE, :long, 1, :string, "handle", :int64, 0, :string, "a" * size)
      channel.sends_packet(FXP_WRITE, :long, 2, :string, "handle", :int64, size, :string, "b" * size)
      channel.sends_packet(FXP_WRITE, :long, 3, :string, "handle", :int64, size*2, :string, "c" * size)
      channel.gets_packet(FXP_STATUS, :long, 1, :long, 0)
      channel.sends_packet(FXP_WRITE, :long, 4, :string, "handle", :int64, size*3, :string, "d" * size)
      channel.gets_packet(FXP_STATUS, :long, 2, :long, 0)
      channel.sends_packet(FXP_CLOSE, :long, 5, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 3, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 4, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 5, :long, 0)
    end

    expect_file("/path/to/local", "a" * size + "b" * size + "c" * size + "d" * size)

    assert_scripted_command do
      opts = {}
      opts[:read_size] = size if requested_size
      sftp.upload("/path/to/local", "/path/to/remote", opts)
    end
  end

  def test_upload_file_with_custom_read_size_should_read_chunks_of_that_size
    test_upload_file_should_read_chunks_of_size(100)
  end

  def test_upload_file_with_custom_requests_should_start_that_many_writes
    size = Net::SFTP::Operations::Upload::DEFAULT_READ_SIZE
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_OPEN, :long, 0, :string, "/path/to/remote", :long, 0x1A, :long, 0)
      channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
      channel.sends_packet(FXP_WRITE, :long, 1, :string, "handle", :int64, 0, :string, "a" * size)
      channel.sends_packet(FXP_WRITE, :long, 2, :string, "handle", :int64, size, :string, "b" * size)
      channel.sends_packet(FXP_WRITE, :long, 3, :string, "handle", :int64, size*2, :string, "c" * size)
      channel.sends_packet(FXP_WRITE, :long, 4, :string, "handle", :int64, size*3, :string, "d" * size)
      channel.gets_packet(FXP_STATUS, :long, 1, :long, 0)
      channel.sends_packet(FXP_CLOSE, :long, 5, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 2, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 3, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 4, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 5, :long, 0)
    end

    expect_file("/path/to/local", "a" * size + "b" * size + "c" * size + "d" * size)

    assert_scripted_command do
      sftp.upload("/path/to/local", "/path/to/remote", :requests => 3)
    end
  end

  def test_upload_directory_should_mirror_directory_structure_remotely
    prepare_directory

    assert_scripted_command do
      sftp.upload("/path/to/local", "/path/to/remote")
    end
  end

  def test_upload_directory_with_handler_should_report_progress
    prepare_directory

    assert_scripted_command do
      sftp.upload("/path/to/local", "/path/to/remote") { |*args| record_progress(args) }
    end

    assert_progress_reported_open(:remote => "/path/to/remote/file1")
    assert_progress_reported_open(:remote => "/path/to/remote/file2")
    assert_progress_reported_open(:remote => "/path/to/remote/file3")
    assert_progress_reported_mkdir("/path/to/remote/subdir")
    assert_progress_reported_open(:remote => "/path/to/remote/subdir/other1")
    assert_progress_reported_open(:remote => "/path/to/remote/subdir/other2")
    assert_progress_reported_put(0, "contents of file1", :remote => "/path/to/remote/file1")
    assert_progress_reported_put(0, "contents of file2", :remote => "/path/to/remote/file2")
    assert_progress_reported_put(0, "contents of file3", :remote => "/path/to/remote/file3")
    assert_progress_reported_close(:remote => "/path/to/remote/file1")
    assert_progress_reported_put(0, "contents of other1", :remote => "/path/to/remote/subdir/other1")
    assert_progress_reported_put(0, "contents of other2", :remote => "/path/to/remote/subdir/other2")
    assert_progress_reported_close(:remote => "/path/to/remote/file2")
    assert_progress_reported_close(:remote => "/path/to/remote/file3")
    assert_progress_reported_close(:remote => "/path/to/remote/subdir/other1")
    assert_progress_reported_close(:remote => "/path/to/remote/subdir/other2")
    assert_progress_reported_finish
    assert_no_more_reported_events
  end

  def test_upload_io_should_send_io_as_file
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_OPEN, :long, 0, :string, "/path/to/remote", :long, 0x1A, :long, 0)
      channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
      channel.sends_packet(FXP_WRITE, :long, 1, :string, "handle", :int64, 0, :string, "this is some text")
      channel.sends_packet(FXP_CLOSE, :long, 2, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 1, :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 2, :long, 0)
    end

    assert_scripted_command do
      sftp.upload(StringIO.new("this is some text"), "/path/to/remote")
    end
  end

  private

    def prepare_directory
      expect_directory("/path/to/local", %w(. .. file1 file2 file3 subdir))
      expect_directory("/path/to/local/subdir", %w(. .. other1 other2))
      expect_file("/path/to/local/file1", "contents of file1")
      expect_file("/path/to/local/file2", "contents of file2")
      expect_file("/path/to/local/file3", "contents of file3")
      expect_file("/path/to/local/subdir/other1", "contents of other1")
      expect_file("/path/to/local/subdir/other2", "contents of other2")

      expect_sftp_session :server_version => 3 do |ch|
        ch.sends_packet(FXP_MKDIR, :long, 0, :string, "/path/to/remote", :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 0, :long, 0)
        ch.sends_packet(FXP_OPEN, :long, 1, :string, "/path/to/remote/file1", :long, 0x1A, :long, 0)
        ch.sends_packet(FXP_OPEN, :long, 2, :string, "/path/to/remote/file2", :long, 0x1A, :long, 0)
        ch.sends_packet(FXP_OPEN, :long, 3, :string, "/path/to/remote/file3", :long, 0x1A, :long, 0)
        ch.sends_packet(FXP_MKDIR, :long, 4, :string, "/path/to/remote/subdir", :long, 0)
        ch.sends_packet(FXP_OPEN, :long, 5, :string, "/path/to/remote/subdir/other1", :long, 0x1A, :long, 0)
        ch.sends_packet(FXP_OPEN, :long, 6, :string, "/path/to/remote/subdir/other2", :long, 0x1A, :long, 0)
        ch.gets_packet(FXP_HANDLE, :long, 1, :string, "hfile1")
        ch.sends_packet(FXP_WRITE, :long, 7, :string, "hfile1", :int64, 0, :string, "contents of file1")
        ch.gets_packet(FXP_HANDLE, :long, 2, :string, "hfile2")
        ch.sends_packet(FXP_WRITE, :long, 8, :string, "hfile2", :int64, 0, :string, "contents of file2")
        ch.gets_packet(FXP_HANDLE, :long, 3, :string, "hfile3")
        ch.sends_packet(FXP_WRITE, :long, 9, :string, "hfile3", :int64, 0, :string, "contents of file3")
        ch.gets_packet(FXP_STATUS, :long, 4, :long, 0)
        ch.gets_packet(FXP_HANDLE, :long, 5, :string, "hother1")
        ch.sends_packet(FXP_CLOSE, :long, 10, :string, "hfile1")
        ch.sends_packet(FXP_WRITE, :long, 11, :string, "hother1", :int64, 0, :string, "contents of other1")
        ch.gets_packet(FXP_HANDLE, :long, 6, :string, "hother2")
        ch.sends_packet(FXP_WRITE, :long, 12, :string, "hother2", :int64, 0, :string, "contents of other2")
        ch.gets_packet(FXP_STATUS, :long, 7, :long, 0)
        ch.sends_packet(FXP_CLOSE, :long, 13, :string, "hfile2")
        ch.gets_packet(FXP_STATUS, :long, 8, :long, 0)
        ch.sends_packet(FXP_CLOSE, :long, 14, :string, "hfile3")
        ch.gets_packet(FXP_STATUS, :long, 9, :long, 0)
        ch.sends_packet(FXP_CLOSE, :long, 15, :string, "hother1")
        ch.gets_packet(FXP_STATUS, :long, 10, :long, 0)
        ch.sends_packet(FXP_CLOSE, :long, 16, :string, "hother2")
        ch.gets_packet(FXP_STATUS, :long, 11, :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 12, :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 13, :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 14, :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 15, :long, 0)
        ch.gets_packet(FXP_STATUS, :long, 16, :long, 0)
      end
    end

    def expect_file(path, data)
      File.stubs(:directory?).with(path).returns(false)
      File.stubs(:exists?).with(path).returns(true)
      file = StringIO.new(data)
      file.stubs(:stat).returns(stub("stat", :size => data.length))
      File.stubs(:open).with(path, "rb").returns(file)
    end

    def expect_directory(path, entries)
      Dir.stubs(:entries).with(path).returns(entries)
      File.stubs(:directory?).with(path).returns(true)
    end

    def expect_file_transfer(local, remote, data)
      expect_sftp_session :server_version => 3 do |channel|
        channel.sends_packet(FXP_OPEN, :long, 0, :string, remote, :long, 0x1A, :long, 0)
        channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
        channel.sends_packet(FXP_WRITE, :long, 1, :string, "handle", :int64, 0, :string, data)
        channel.sends_packet(FXP_CLOSE, :long, 2, :string, "handle")
        channel.gets_packet(FXP_STATUS, :long, 1, :long, 0)
        channel.gets_packet(FXP_STATUS, :long, 2, :long, 0)
      end

      expect_file(local, data)
    end
end