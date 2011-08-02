require "common"

class FileFactoryTest < Net::SFTP::TestCase
  def setup
    @sftp = stub(:sftp)
    @factory = Net::SFTP::Operations::FileFactory.new(@sftp)
  end

  def test_open_with_block_should_yield_and_close_handle
    @sftp.expects(:open!).with("/path/to/remote", "r", :permissions => nil).returns("handle")
    @sftp.expects(:close!).with("handle")

    called = false
    @factory.open("/path/to/remote") do |f|
      called = true
      assert_instance_of Net::SFTP::Operations::File, f
    end

    assert called
  end

  def test_open_with_block_should_close_file_even_if_exception_is_raised
    @sftp.expects(:open!).with("/path/to/remote", "r", :permissions => nil).returns("handle")
    @sftp.expects(:close!).with("handle")

    assert_raises(RuntimeError) do
      @factory.open("/path/to/remote") { |f| raise RuntimeError, "b00m" }
    end
  end

  def test_open_without_block_should_return_new_file
    @sftp.expects(:open!).with("/path/to/remote", "r", :permissions => nil).returns("handle")
    @sftp.expects(:close!).never

    f = @factory.open("/path/to/remote")
    assert_instance_of Net::SFTP::Operations::File, f
  end

  def test_directory_should_be_true_for_directory
    @sftp.expects(:lstat!).with("/path/to/dir").returns(mock('attrs', :directory? => true))
    assert @factory.directory?("/path/to/dir")
  end

  def test_directory_should_be_false_for_non_directory
    @sftp.expects(:lstat!).with("/path/to/file").returns(mock('attrs', :directory? => false))
    assert !@factory.directory?("/path/to/file")
  end
end