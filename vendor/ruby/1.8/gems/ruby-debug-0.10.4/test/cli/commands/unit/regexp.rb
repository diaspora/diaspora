require 'test/unit'


class TestCommandREs < Test::Unit::TestCase
  base_dir=File.expand_path(File.join(File.dirname(__FILE__), 
                                      '..', '..', '..', '..',
                                      'cli', 'ruby-debug'))
  require File.join(base_dir, 'command')
  require File.join(base_dir, 'commands', 'frame')
  include Debugger
 
  def test_quit
    c = QuitCommand.new(nil)
    assert c.regexp.match('quit')
    assert c.regexp.match('q')
    assert c.regexp.match('quit!')
    assert c.regexp.match('q!')
    assert c.regexp.match('quit unconditionally')
    assert c.regexp.match('exit')
    assert c.regexp.match('exit!')
  end

  def test_up
    c = UpCommand.new(nil)
    assert c.regexp.match('up')
    assert c.regexp.match('up 2')
    assert c.regexp.match('up 2+5')
    assert c.regexp.match('u')
    assert c.regexp.match('u 2')
    assert_equal nil, c.regexp.match('ufoo')
  end

  def test_down
    c = DownCommand.new(nil)
    assert c.regexp.match('down')
    assert c.regexp.match('down 2')
    assert_equal(nil, c.regexp.match('d 2'))
    assert_equal(nil, c.regexp.match('d'))
    assert_equal(nil, c.regexp.match('dow'))
  end
end

