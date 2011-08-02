lib_dir = File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/linked_rails'

require 'test/unit'
require 'fileutils'
$:.unshift lib_dir unless $:.include?(lib_dir)
require 'haml'

require 'haml/template'
Haml::Template.options[:ugly] = false
Haml::Template.options[:format] = :xhtml

class Test::Unit::TestCase
  def assert_warning(message)
    the_real_stderr, $stderr = $stderr, StringIO.new
    yield

    if message.is_a?(Regexp)
      assert_match message, $stderr.string.strip
    else
      assert_equal message.strip, $stderr.string.strip
    end
  ensure
    $stderr = the_real_stderr
  end

  def silence_warnings(&block)
    Haml::Util.silence_warnings(&block)
  end

  def rails_block_helper_char
    return '=' if Haml::Util.ap_geq_3?
    return '-'
  end

  def form_for_calling_convention(name)
    return "@#{name}, :as => :#{name}, :html => {:class => nil, :id => nil}" if Haml::Util.ap_geq_3?
    return ":#{name}, @#{name}"
  end

  def rails_form_attr
    return 'accept-charset="UTF-8" ' if Haml::Util.ap_geq?("3.0.0.rc")
    return ''
  end

  def rails_form_opener
    return '' unless Haml::Util.ap_geq?("3.0.0.rc")
    if Haml::Util.ap_geq?("3.0.0.rc2")
      encoding = 'utf8'
      char = '&#x2713;'
    else
      encoding = '_snowman'
      char = '&#9731;'
    end
    return '<div style="margin:0;padding:0;display:inline"><input name="' + encoding +
      '" type="hidden" value="' + char + '" /></div>'
  end

  def assert_raise_message(klass, message)
    yield
  rescue Exception => e
    assert_instance_of(klass, e)
    assert_equal(message, e.message)
  else
    flunk "Expected exception #{klass}, none raised"
  end

  def assert_raise_line(line)
    yield
  rescue Sass::SyntaxError => e
    assert_equal(line, e.sass_line)
  else
    flunk "Expected exception on line #{line}, none raised"
  end
end
