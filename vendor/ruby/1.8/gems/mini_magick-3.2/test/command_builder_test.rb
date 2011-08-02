require 'rubygems'
require 'test/unit'
require File.expand_path('../../lib/mini_magick', __FILE__)

class CommandBuilderTest < Test::Unit::TestCase
  include MiniMagick

  def test_basic
    c = CommandBuilder.new("test")
    c.resize "30x40"
    assert_equal "-resize \"30x40\"", c.args.join(" ")
  end

  def test_complicated
    c = CommandBuilder.new("test")
    c.resize "30x40"
    c.alpha "1 3 4"
    c.resize "mome fingo"
    assert_equal "-resize \"30x40\" -alpha \"1 3 4\" -resize \"mome fingo\"", c.args.join(" ")
  end

  def test_plus_modifier_and_multiple_options
    c = CommandBuilder.new("test")
    c.distort.+ 'srt', '0.6 20'
    assert_equal "+distort \"srt\" \"0.6 20\"", c.args.join(" ")
  end
  
  def test_valid_command
    begin
      c = CommandBuilder.new("test", "path")
      c.input 2
      assert false
    rescue NoMethodError
      assert true
    end
  end

  def test_dashed
    c = CommandBuilder.new("test")
    c.auto_orient
    assert_equal "-auto-orient", c.args.join(" ")
  end
end
