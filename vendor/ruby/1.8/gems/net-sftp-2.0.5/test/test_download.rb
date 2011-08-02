require "common"

class DownloadTest < Net::SFTP::TestCase
  def setup
    prepare_progress!
  end

  def test_download_file_should_transfer_remote_to_local
    local = "/path/to/local"
    remote = "/path/to/remote"
    text = "this is some text\n"

    expect_file_transfer(remote, text)

    file = StringIO.new
    File.stubs(:open).with(local, "wb").returns(file)

    assert_scripted_command { sftp.download(remote, local) }
    assert_equal text, file.string
  end

  def test_download_large_file_should_transfer_remote_to_local
    local = "/path/to/local"
    remote = "/path/to/remote"
    text = "0123456789" * 1024

    file = prepare_large_file_download(local, remote, text)

    assert_scripted_command { sftp.download(remote, local, :read_size => 1024) }
    assert_equal text, file.string
  end

  def test_download_large_file_with_progress_should_report_progress
    local = "/path/to/local"
    remote = "/path/to/remote"
    text = "0123456789" * 1024

    file = prepare_large_file_download(local, remote, text)

    assert_scripted_command do
      sftp.download(remote, local, :read_size => 1024) do |*args|
        record_progress(args)
      end
    end

    assert_equal text, file.string

    assert_progress_reported_open :remote => "/path/to/remote"
    assert_progress_reported_get     0, 1024
    assert_progress_reported_get  1024, 1024
    assert_progress_reported_get  2048, 1024
    assert_progress_reported_get  3072, 1024
    assert_progress_reported_get  4096, 1024
    assert_progress_reported_get  5120, 1024
    assert_progress_reported_get  6144, 1024
    assert_progress_reported_get  7168, 1024
    assert_progress_reported_get  8192, 1024
    assert_progress_reported_get  9216, 1024
    assert_progress_reported_close
    assert_progress_reported_finish
    assert_no_more_reported_events
  end

  def test_download_directory_should_mirror_directory_locally
    file1, file2 = prepare_directory_tree_download("/path/to/local", "/path/to/remote")

    assert_scripted_command do
      sftp.download("/path/to/remote", "/path/to/local", :recursive => true)
    end

    assert_equal "contents of file1", file1.string
    assert_equal "contents of file2", file2.string
  end

  def test_download_directory_with_progress_should_report_progress
    file1, file2 = prepare_directory_tree_download("/path/to/local", "/path/to/remote")

    assert_scripted_command do
      sftp.download("/path/to/remote", "/path/to/local", :recursive => true) do |*args|
        record_progress(args)
      end
    end

    assert_equal "contents of file1", file1.string
    assert_equal "contents of file2", file2.string

    assert_progress_reported_mkdir "/path/to/local"
    assert_progress_reported_mkdir "/path/to/local/subdir1"
    assert_progress_reported_open  :remote => "/path/to/remote/file1"
    assert_progress_reported_open  :remote => "/path/to/remote/subdir1/file2"
    assert_progress_reported_get   0, "contents of file1"
    assert_progress_reported_close :remote => "/path/to/remote/file1"
    assert_progress_reported_get   0, "contents of file2"
    assert_progress_reported_close :remote => "/path/to/remote/subdir1/file2"
    assert_progress_reported_finish
    assert_no_more_reported_events
  end

  def test_download_file_should_transfer_remote_to_local_buffer
    remote = "/path/to/remote"
    text = "this is some text\n"

    expect_file_transfer(remote, text)

    local = StringIO.new

    assert_scripted_command { sftp.download(remote, local) }
    assert_equal text, local.string
  end

  def test_download_directory_to_buffer_should_fail
    expect_sftp_session :server_version => 3
    assert_raises(ArgumentError) { sftp.download("/path/to/remote", StringIO.new, :recursive => true) }
  end

  private

    def expect_file_transfer(remote, text)
      expect_sftp_session :server_version => 3 do |channel|
        channel.sends_packet(FXP_OPEN, :long, 0, :string, remote, :long, 0x01, :long, 0)
        channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
        channel.sends_packet(FXP_READ, :long, 1, :string, "handle", :int64, 0, :long, 32_000)
        channel.gets_packet(FXP_DATA, :long, 1, :string, text)
        channel.sends_packet(FXP_READ, :long, 2, :string, "handle", :int64, 32_000, :long, 32_000)
        channel.gets_packet(FXP_STATUS, :long, 2, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 3, :string, "handle")
        channel.gets_packet(FXP_STATUS, :long, 3, :long, 0)
      end
    end

    def prepare_large_file_download(local, remote, text)
      expect_sftp_session :server_version => 3 do |channel|
        channel.sends_packet(FXP_OPEN, :long, 0, :string, remote, :long, 0x01, :long, 0)
        channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
        10.times do |n|
          channel.sends_packet(FXP_READ, :long, n+1, :string, "handle", :int64, n*1024, :long, 1024)
          channel.gets_packet(FXP_DATA, :long, n+1, :string, text[n*1024,1024])
        end
        channel.sends_packet(FXP_READ, :long, 11, :string, "handle", :int64, 10240, :long, 1024)
        channel.gets_packet(FXP_STATUS, :long, 11, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 12, :string, "handle")
        channel.gets_packet(FXP_STATUS, :long, 12, :long, 0)
      end
      
      file = StringIO.new
      File.stubs(:open).with(local, "wb").returns(file)

      return file
    end

    # 0:OPENDIR(remote) ->
    # <- 0:HANDLE("dir1")
    # 1:READDIR("dir1") ->
    # <- 1:NAME("..", ".", "subdir1", "file1")
    # 2:OPENDIR(remote/subdir1) ->
    # 3:OPEN(remote/file1) ->
    # 4:READDIR("dir1") ->
    # <- 2:HANDLE("dir2")
    # 5:READDIR("dir2") ->
    # <- 3:HANDLE("file1")
    # 6:READ("file1", 0, 32k) ->
    # <- 4:STATUS(1)
    # 7:CLOSE("dir1") ->
    # <- 5:NAME("..", ".", "file2")
    # 8:OPEN(remote/subdir1/file2) ->
    # 9:READDIR("dir2") ->
    # <- 6:DATA("blah blah blah")
    # 10:READ("file1", n, 32k)
    # <- 7:STATUS(0)
    # <- 8:HANDLE("file2")
    # 11:READ("file2", 0, 32k) ->
    # <- 9:STATUS(1)
    # 12:CLOSE("dir2") ->
    # <- 10:STATUS(1)
    # 13:CLOSE("file1") ->
    # <- 11:DATA("blah blah blah")
    # 14:READ("file2", n, 32k) ->
    # <- 12:STATUS(0)
    # <- 13:STATUS(0)
    # <- 14:STATUS(1)
    # 15:CLOSE("file2") ->
    # <- 15:STATUS(0)

    def prepare_directory_tree_download(local, remote)
      expect_sftp_session :server_version => 3 do |channel|
        channel.sends_packet(FXP_OPENDIR, :long, 0, :string, remote)
        channel.gets_packet(FXP_HANDLE, :long, 0, :string, "dir1")

        channel.sends_packet(FXP_READDIR, :long, 1, :string, "dir1")
        channel.gets_packet(FXP_NAME, :long, 1, :long, 4,
          :string, "..",      :string, "drwxr-xr-x  4 bob bob  136 Aug  1 ..", :long, 0x04, :long, 040755,
          :string, ".",       :string, "drwxr-xr-x  4 bob bob  136 Aug  1 .", :long, 0x04, :long, 040755,
          :string, "subdir1", :string, "drwxr-xr-x  4 bob bob  136 Aug  1 subdir1", :long, 0x04, :long, 040755,
          :string, "file1",   :string, "-rw-rw-r--  1 bob bob  100 Aug  1 file1", :long, 0x04, :long, 0100644)

        channel.sends_packet(FXP_OPENDIR, :long, 2, :string, File.join(remote, "subdir1"))
        channel.sends_packet(FXP_OPEN, :long, 3, :string, File.join(remote, "file1"), :long, 0x01, :long, 0)
        channel.sends_packet(FXP_READDIR, :long, 4, :string, "dir1")

        channel.gets_packet(FXP_HANDLE, :long, 2, :string, "dir2")
        channel.sends_packet(FXP_READDIR, :long, 5, :string, "dir2")

        channel.gets_packet(FXP_HANDLE, :long, 3, :string, "file1")
        channel.sends_packet(FXP_READ, :long, 6, :string, "file1", :int64, 0, :long, 32_000)

        channel.gets_packet(FXP_STATUS, :long, 4, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 7, :string, "dir1")

        channel.gets_packet(FXP_NAME, :long, 5, :long, 3,
          :string, "..",    :string, "drwxr-xr-x  4 bob bob  136 Aug  1 ..", :long, 0x04, :long, 040755,
          :string, ".",     :string, "drwxr-xr-x  4 bob bob  136 Aug  1 .", :long, 0x04, :long, 040755,
          :string, "file2", :string, "-rw-rw-r--  1 bob bob  100 Aug  1 file2", :long, 0x04, :long, 0100644)

        channel.sends_packet(FXP_OPEN, :long, 8, :string, File.join(remote, "subdir1", "file2"), :long, 0x01, :long, 0)
        channel.sends_packet(FXP_READDIR, :long, 9, :string, "dir2")

        channel.gets_packet(FXP_DATA, :long, 6, :string, "contents of file1")
        channel.sends_packet(FXP_READ, :long, 10, :string, "file1", :int64, 32_000, :long, 32_000)

        channel.gets_packet(FXP_STATUS, :long, 7, :long, 0)
        channel.gets_packet(FXP_HANDLE, :long, 8, :string, "file2")
        channel.sends_packet(FXP_READ, :long, 11, :string, "file2", :int64, 0, :long, 32_000)

        channel.gets_packet(FXP_STATUS, :long, 9, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 12, :string, "dir2")

        channel.gets_packet(FXP_STATUS, :long, 10, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 13, :string, "file1")

        channel.gets_packet(FXP_DATA, :long, 11, :string, "contents of file2")
        channel.sends_packet(FXP_READ, :long, 14, :string, "file2", :int64, 32_000, :long, 32_000)

        channel.gets_packet(FXP_STATUS, :long, 12, :long, 0)
        channel.gets_packet(FXP_STATUS, :long, 13, :long, 0)
        channel.gets_packet(FXP_STATUS, :long, 14, :long, 1)
        channel.sends_packet(FXP_CLOSE, :long, 15, :string, "file2")
        channel.gets_packet(FXP_STATUS, :long, 15, :long, 0)
      end

      File.expects(:directory?).with(local).returns(false)
      File.expects(:directory?).with(File.join(local, "subdir1")).returns(false)
      Dir.expects(:mkdir).with(local)
      Dir.expects(:mkdir).with(File.join(local, "subdir1"))

      file1 = StringIO.new
      file2 = StringIO.new
      File.expects(:open).with(File.join(local, "file1"), "wb").returns(file1)
      File.expects(:open).with(File.join(local, "subdir1", "file2"), "wb").returns(file2)

      [file1, file2]
    end
end