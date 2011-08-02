require 'common'

class Protocol::V04::TestName < Net::SFTP::TestCase
  def setup
    @save_tz   = ENV['TZ']
    ENV['TZ']  = 'UTC'

    @directory = Net::SFTP::Protocol::V04::Name.new("test", Net::SFTP::Protocol::V04::Attributes.new(:type => 2, :mtime => 1205293237, :owner => "jamis", :group => "users", :size => 1024, :permissions => 0755))
    @link      = Net::SFTP::Protocol::V04::Name.new("test", Net::SFTP::Protocol::V04::Attributes.new(:type => 3, :mtime => 1205293237, :owner => "jamis", :group => "users", :size => 32, :permissions => 0755))
    @file      = Net::SFTP::Protocol::V04::Name.new("test", Net::SFTP::Protocol::V04::Attributes.new(:type => 1, :mtime => 1205293237, :owner => "jamis", :group => "users", :size => 10240, :permissions => 0755))
  end

  def teardown
    if @save_tz
      ENV['TZ'] = @save_tz
    else
      ENV.delete('TZ')
    end
  end

  def test_directory?
    assert @directory.directory?
    assert !@link.directory?
    assert !@file.directory?
  end

  def test_symlink?
    assert !@directory.symlink?
    assert @link.symlink?
    assert !@file.symlink?
  end

  def test_file?
    assert !@directory.file?
    assert !@link.file?
    assert @file.file?
  end

  def test_longname_for_directory_should_format_as_directory
    assert_equal "drwxr-xr-x jamis    users        1024 Mar 12 03:40 test",
      @directory.longname
  end

  def test_longname_for_symlink_should_format_as_symlink
    assert_equal "lrwxr-xr-x jamis    users          32 Mar 12 03:40 test",
      @link.longname
  end

  def test_longname_for_file_should_format_as_file
    assert_equal "-rwxr-xr-x jamis    users       10240 Mar 12 03:40 test",
      @file.longname
  end
end
