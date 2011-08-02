require 'common'

class TestUpload < Net::SCP::TestCase
  def test_upload_file_should_transfer_file
    prepare_file("/path/to/local.txt", "a" * 1234)

    expect_scp_session "-t /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0666 1234 local.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local.txt", "/path/to/remote.txt") }
  end
  
  def test_upload_file_with_spaces_in_name_should_escape_remote_file_name
    prepare_file("/path/to/local file.txt", "")

    expect_scp_session "-t /path/to/remote\\ file.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0666 0 local file.txt\n"
      channel.gets_ok
      channel.sends_ok
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local file.txt", "/path/to/remote file.txt") }
  end
  
  def test_upload_file_with_metacharacters_in_name_should_escape_remote_file_name
    prepare_file("/path/to/local/#{awful_file_name}", "")

    expect_scp_session "-t /path/to/remote/#{escaped_file_name}" do |channel|
      channel.gets_ok
      channel.sends_data "C0666 0 #{awful_file_name}\n"
      channel.gets_ok
      channel.sends_ok
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local/#{awful_file_name}", "/path/to/remote/#{awful_file_name}") }
  end

  def test_upload_file_with_preserve_should_send_times
    prepare_file("/path/to/local.txt", "a" * 1234, 0666, Time.at(1234567890, 123456), Time.at(1234543210, 345678))

    expect_scp_session "-t -p /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "T1234567890 123456 1234543210 345678\n"
      channel.gets_ok
      channel.sends_data "C0666 1234 local.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local.txt", "/path/to/remote.txt", :preserve => true) }
  end

  def test_upload_file_with_progress_callback_should_invoke_callback
    prepare_file("/path/to/local.txt", "a" * 3000 + "b" * 3000 + "c" * 3000 + "d" * 3000)

    expect_scp_session "-t /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0666 12000 local.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 3000
      channel.sends_data "b" * 3000
      channel.sends_data "c" * 3000
      channel.sends_data "d" * 3000
      channel.sends_ok
      channel.gets_ok
    end

    calls = []
    progress = Proc.new do |ch, name, sent, total|
      calls << [name, sent, total]
    end

    assert_scripted do
      scp.upload!("/path/to/local.txt", "/path/to/remote.txt", :chunk_size => 3000, &progress)
    end

    assert_equal ["/path/to/local.txt",     0, 12000], calls.shift
    assert_equal ["/path/to/local.txt",  3000, 12000], calls.shift
    assert_equal ["/path/to/local.txt",  6000, 12000], calls.shift
    assert_equal ["/path/to/local.txt",  9000, 12000], calls.shift
    assert_equal ["/path/to/local.txt", 12000, 12000], calls.shift
    assert calls.empty?
  end

  def test_upload_io_with_recursive_should_ignore_recursive
    expect_scp_session "-t -r /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0640 1234 remote.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    io = StringIO.new("a" * 1234)
    assert_scripted { scp.upload!(io, "/path/to/remote.txt", :recursive => true) }
  end

  def test_upload_io_with_preserve_should_ignore_preserve
    expect_scp_session "-t -p /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0640 1234 remote.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    io = StringIO.new("a" * 1234)
    assert_scripted { scp.upload!(io, "/path/to/remote.txt", :preserve  => true) }
  end

  def test_upload_io_should_transfer_data
    expect_scp_session "-t /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0640 1234 remote.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    io = StringIO.new("a" * 1234)
    assert_scripted { scp.upload!(io, "/path/to/remote.txt") }
  end

  def test_upload_io_with_mode_should_honor_mode_as_permissions
    expect_scp_session "-t /path/to/remote.txt" do |channel|
      channel.gets_ok
      channel.sends_data "C0666 1234 remote.txt\n"
      channel.gets_ok
      channel.sends_data "a" * 1234
      channel.sends_ok
      channel.gets_ok
    end

    io = StringIO.new("a" * 1234)
    assert_scripted { scp.upload!(io, "/path/to/remote.txt", :mode => 0666) }
  end

  def test_upload_directory_without_recursive_should_error
    prepare_directory("/path/to/local")

    expect_scp_session("-t /path/to/remote") do |channel|
      channel.gets_ok
    end

    assert_raises(Net::SCP::Error) { scp.upload!("/path/to/local", "/path/to/remote") }
  end

  def test_upload_empty_directory_should_create_directory_and_finish
    prepare_directory("/path/to/local")

    expect_scp_session("-t -r /path/to/remote") do |channel|
      channel.gets_ok
      channel.sends_data "D0777 0 local\n"
      channel.gets_ok
      channel.sends_data "E\n"
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local", "/path/to/remote", :recursive => true) }
  end

  def test_upload_directory_should_recursively_create_and_upload_items
    prepare_directory("/path/to/local") do |d|
      d.file "hello.txt", "hello world\n"
      d.directory "others" do |d2|
        d2.file "data.dat", "abcdefghijklmnopqrstuvwxyz"
      end
      d.file "zoo.doc", "going to the zoo\n"
    end

    expect_scp_session("-t -r /path/to/remote") do |channel|
      channel.gets_ok
      channel.sends_data "D0777 0 local\n"
      channel.gets_ok
      channel.sends_data "C0666 12 hello.txt\n"
      channel.gets_ok
      channel.sends_data "hello world\n"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "D0777 0 others\n"
      channel.gets_ok
      channel.sends_data "C0666 26 data.dat\n"
      channel.gets_ok
      channel.sends_data "abcdefghijklmnopqrstuvwxyz"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "E\n"
      channel.gets_ok
      channel.sends_data "C0666 17 zoo.doc\n"
      channel.gets_ok
      channel.sends_data "going to the zoo\n"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "E\n"
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local", "/path/to/remote", :recursive => true) }
  end

  def test_upload_directory_with_preserve_should_send_times_for_all_items
    prepare_directory("/path/to/local", 0755, Time.at(17171717, 191919), Time.at(18181818, 101010)) do |d|
      d.file "hello.txt", "hello world\n", 0640, Time.at(12345, 67890), Time.at(234567, 890)
      d.directory "others", 0770, Time.at(112233, 4455), Time.at(22334455, 667788) do |d2|
        d2.file "data.dat", "abcdefghijklmnopqrstuvwxyz", 0600, Time.at(13579135, 13131), Time.at(7654321, 654321)
      end
      d.file "zoo.doc", "going to the zoo\n", 0444, Time.at(12121212, 131313), Time.at(23232323, 242424)
    end

    expect_scp_session("-t -r -p /path/to/remote") do |channel|
      channel.gets_ok
      channel.sends_data "T17171717 191919 18181818 101010\n"
      channel.gets_ok
      channel.sends_data "D0755 0 local\n"
      channel.gets_ok
      channel.sends_data "T12345 67890 234567 890\n"
      channel.gets_ok
      channel.sends_data "C0640 12 hello.txt\n"
      channel.gets_ok
      channel.sends_data "hello world\n"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "T112233 4455 22334455 667788\n"
      channel.gets_ok
      channel.sends_data "D0770 0 others\n"
      channel.gets_ok
      channel.sends_data "T13579135 13131 7654321 654321\n"
      channel.gets_ok
      channel.sends_data "C0600 26 data.dat\n"
      channel.gets_ok
      channel.sends_data "abcdefghijklmnopqrstuvwxyz"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "E\n"
      channel.gets_ok
      channel.sends_data "T12121212 131313 23232323 242424\n"
      channel.gets_ok
      channel.sends_data "C0444 17 zoo.doc\n"
      channel.gets_ok
      channel.sends_data "going to the zoo\n"
      channel.sends_ok
      channel.gets_ok
      channel.sends_data "E\n"
      channel.gets_ok
    end

    assert_scripted { scp.upload!("/path/to/local", "/path/to/remote", :preserve => true, :recursive => true) }
  end

  def test_upload_should_not_block
    prepare_file("/path/to/local.txt", "data")
    story { |s| s.opens_channel(false) }
    assert_scripted { scp.upload("/path/to/local.txt", "/path/to/remote.txt") }
  end
end
