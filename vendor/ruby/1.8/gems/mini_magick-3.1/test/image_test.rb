require 'rubygems'
require 'test/unit'
require 'mocha'
require 'pathname'
require 'stringio'
require File.expand_path('../../lib/mini_magick', __FILE__)

#MiniMagick.processor = :gm

class ImageTest < Test::Unit::TestCase
  include MiniMagick

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__)) + "/"

  SIMPLE_IMAGE_PATH = CURRENT_DIR + "simple.gif"
  MINUS_IMAGE_PATH  = CURRENT_DIR + "simple-minus.gif"
  TIFF_IMAGE_PATH   = CURRENT_DIR + "leaves spaced.tiff"
  NOT_AN_IMAGE_PATH = CURRENT_DIR + "not_an_image.php"
  GIF_WITH_JPG_EXT  = CURRENT_DIR + "actually_a_gif.jpg"
  EXIF_IMAGE_PATH   = CURRENT_DIR + "trogdor.jpg"
  ANIMATION_PATH    = CURRENT_DIR + "animation.gif"

  def test_image_from_blob
    File.open(SIMPLE_IMAGE_PATH, "rb") do |f|
      image = Image.read(f.read)
      assert image.valid?
      image.destroy!
    end
  end

  def test_image_open
    image = Image.open(SIMPLE_IMAGE_PATH)
    assert image.valid?
    image.destroy!
  end

  def test_image_io_reading
    buffer = StringIO.new(File.read(SIMPLE_IMAGE_PATH))
    image = Image.read(buffer)
    image.destroy!
  end

  def test_image_create
    image = Image.create do |f|
      f.write(File.read(SIMPLE_IMAGE_PATH))
    end
    image.destroy!
  end

  def test_image_new
    image = Image.new(SIMPLE_IMAGE_PATH)
    image.destroy!
  end

  def test_remote_image
    image = Image.open("http://www.google.com/images/logos/logo.png")
    image.valid?
    image.destroy!
  end

  def test_image_write
    output_path = "output.gif"
    begin
      image = Image.new(SIMPLE_IMAGE_PATH)
      image.write output_path

      assert File.exists?(output_path)
    ensure
      File.delete output_path
    end
    image.destroy!
  end

  def test_image_write_with_stream
    stream = StringIO.new
    image = Image.open(SIMPLE_IMAGE_PATH)
    image.write("/tmp/foo.gif")
    image.write(stream)
#    assert Image.read(stream.string).valid?
    image.destroy!
  end

  def test_not_an_image
    image = Image.new(NOT_AN_IMAGE_PATH)
    assert_equal false, image.valid?
    image.destroy!
  end

  def test_throw_on_openining_not_an_image
    assert_raise(MiniMagick::Invalid) do
      image = Image.open(NOT_AN_IMAGE_PATH)
      image.destroy
    end
  end

  def test_image_meta_info
    image = Image.new(SIMPLE_IMAGE_PATH)
    assert_equal 150, image[:width]
    assert_equal 55, image[:height]
    assert_equal [150, 55], image[:dimensions]
    assert_match(/^gif$/i, image[:format])
    image.destroy!
  end

  def test_tiff
    image = Image.new(TIFF_IMAGE_PATH)
    assert_equal "tiff", image[:format].downcase
    assert_equal 50, image[:width]
    assert_equal 41, image[:height]
    image.destroy!
  end

  def test_gif_with_jpg_format
    image = Image.new(GIF_WITH_JPG_EXT)
    assert_equal "gif", image[:format].downcase
    image.destroy!
  end

  def test_image_resize
    image = Image.open(SIMPLE_IMAGE_PATH)
    image.resize "20x30!"

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
    image.destroy!
  end

  def test_image_resize_with_minimum
    image = Image.open(SIMPLE_IMAGE_PATH)
    original_width, original_height = image[:width], image[:height]
    image.resize "#{original_width + 10}x#{original_height + 10}>"

    assert_equal original_width, image[:width]
    assert_equal original_height, image[:height]
    image.destroy!
  end

  def test_image_combine_options_resize_blur
    image = Image.open(SIMPLE_IMAGE_PATH)
    image.combine_options do |c|
      c.resize "20x30!"
      c.blur "50"
    end

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
    image.destroy!
  end

  def test_image_combine_options_with_filename_with_minusses_in_it
    image = Image.open(SIMPLE_IMAGE_PATH)
    background = "#000000"
    assert_nothing_raised do
      image.combine_options do |c|
        c.draw "image Over 0,0 10,10 '#{MINUS_IMAGE_PATH}'"
        c.thumbnail "300x500>"
        c.background background
      end
    end
    image.destroy!
  end

  def test_exif
    image = Image.open(EXIF_IMAGE_PATH)
    assert_equal('0220', image["exif:ExifVersion"])
    image = Image.open(SIMPLE_IMAGE_PATH)
    assert_equal('', image["EXIF:ExifVersion"])
    image.destroy!
  end

  def test_original_at
    image = Image.open(EXIF_IMAGE_PATH)
    assert_equal(Time.local('2005', '2', '23', '23', '17', '24'), image[:original_at])
    image = Image.open(SIMPLE_IMAGE_PATH)
    assert_nil(image[:original_at])
    image.destroy!
  end

  def test_tempfile_at_path
    image = Image.open(TIFF_IMAGE_PATH)
    assert_equal image.path, image.instance_eval("@tempfile.path")
    image.destroy!
  end

  def test_tempfile_at_path_after_format
    image = Image.open(TIFF_IMAGE_PATH)
    image.format('png')
    assert_equal image.path, image.instance_eval("@tempfile.path")
    image.destroy!
  end

  def test_previous_tempfile_deleted_after_format
    image = Image.open(TIFF_IMAGE_PATH)
    before = image.path.dup
    image.format('png')
    assert !File.exist?(before)
    image.destroy!
  end

  def test_bad_method_bug
    image = Image.open(TIFF_IMAGE_PATH)
    begin
      image.to_blog
    rescue NoMethodError
      assert true
    end
    image.to_blob
    assert true #we made it this far without error
    image.destroy!
  end

  def test_simple_composite
    image = Image.open(EXIF_IMAGE_PATH)
    result = image.composite(Image.open(TIFF_IMAGE_PATH)) do |c|
      c.gravity "center"
    end
    assert `diff -s #{result.path} test/composited.jpg`.include?("identical")
  end

  # http://github.com/probablycorey/mini_magick/issues#issue/8
  def test_issue_8
    image = Image.open(SIMPLE_IMAGE_PATH)
    assert_nothing_raised do
      image.combine_options do |c|
        c.sample "50%"
        c.rotate "-90>"
      end
    end
    image.destroy!
  end

  # http://github.com/probablycorey/mini_magick/issues#issue/15
  def test_issue_15
    image = Image.open(Pathname.new(SIMPLE_IMAGE_PATH))
    output = Pathname.new("test.gif")
    image.write(output)
  ensure
    FileUtils.rm("test.gif")
  end

  def test_throw_format_error
    image = Image.open(SIMPLE_IMAGE_PATH)
    assert_raise MiniMagick::Error do
      image.combine_options do |c|
        c.format "png"
      end
    end
    image.destroy!
  end

  # testing that if copying files formatted from an animation fails,
  # it raises an appropriate error
  def test_throw_animation_copy_after_format_error
    image = Image.open(ANIMATION_PATH)
    FileUtils.stubs(:copy_file).raises(Errno::ENOENT)
    assert_raises MiniMagick::Error do
      image.format('png')
    end
  end


end
