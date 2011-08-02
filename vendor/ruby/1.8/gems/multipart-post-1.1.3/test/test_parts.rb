require 'test/unit'

require 'parts'
require 'stringio'
require 'composite_io'

class FilePartTest < Test::Unit::TestCase
  TEMP_FILE = "temp.txt"

  def setup
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    io =  UploadIO.new(TEMP_FILE, "text/plain")
    @part = Parts::FilePart.new("boundary", "afile", io)
  end

  def teardown
    File.delete(TEMP_FILE) rescue nil
  end

  def test_correct_length
    assert_equal @part.length, @part.to_io.read.length
  end
end
