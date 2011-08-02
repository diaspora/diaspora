require 'common'

class Protocol::V01::TestName < Net::SFTP::TestCase
  def setup
    @directory = Net::SFTP::Protocol::V01::Name.new("test", "drwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test", Net::SFTP::Protocol::V01::Attributes.new(:permissions => 040755))
    @link      = Net::SFTP::Protocol::V01::Name.new("test", "lrwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test", Net::SFTP::Protocol::V01::Attributes.new(:permissions => 0120755))
    @file      = Net::SFTP::Protocol::V01::Name.new("test", "-rwxr-x-r-x  89 test  test  3026 Mar 10 17:45 test", Net::SFTP::Protocol::V01::Attributes.new(:permissions => 0100755))
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
end