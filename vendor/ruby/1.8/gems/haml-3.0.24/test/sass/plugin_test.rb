#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require 'sass/plugin'
require 'fileutils'

class SassPluginTest < Test::Unit::TestCase
  @@templates = %w{
    complex script parent_ref import scss_import alt
    subdir/subdir subdir/nested_subdir/nested_subdir
    options
  }
  @@templates += %w[import_charset import_charset_ibm866] unless Haml::Util.ruby1_8?
  @@templates << 'import_charset_1_8' if Haml::Util.ruby1_8?

  def setup
    FileUtils.mkdir tempfile_loc
    FileUtils.mkdir tempfile_loc(nil,"more_")
    set_plugin_opts
    update_all_stylesheets!
    reset_mtimes
  end

  def teardown
    clean_up_sassc
    clear_callbacks
    FileUtils.rm_r tempfile_loc
    FileUtils.rm_r tempfile_loc(nil,"more_")
  end

  @@templates.each do |name|
    define_method("test_template_renders_correctly (#{name})") do
      assert_renders_correctly(name)
    end
  end

  def test_no_update
    File.delete(tempfile_loc('basic'))
    assert_needs_update 'basic'
    update_all_stylesheets!
    assert_stylesheet_updated 'basic'
  end

  def test_update_needed_when_modified
    touch 'basic'
    assert_needs_update 'basic'
    update_all_stylesheets!
    assert_stylesheet_updated 'basic'
  end

  def test_update_needed_when_dependency_modified
    touch 'basic'
    assert_needs_update 'import'
    update_all_stylesheets!
    assert_stylesheet_updated 'basic'
    assert_stylesheet_updated 'import'
  end

  def test_update_needed_when_scss_dependency_modified
    touch 'scss_importee'
    assert_needs_update 'import'
    update_all_stylesheets!
    assert_stylesheet_updated 'scss_importee'
    assert_stylesheet_updated 'import'
  end

  def test_scss_update_needed_when_dependency_modified
    touch 'basic'
    assert_needs_update 'scss_import'
    update_all_stylesheets!
    assert_stylesheet_updated 'basic'
    assert_stylesheet_updated 'scss_import'
  end

  def test_full_exception_handling
    File.delete(tempfile_loc('bork1'))
    update_all_stylesheets!
    File.open(tempfile_loc('bork1')) do |file|
      assert_equal(<<CSS.strip, file.read.split("\n")[0...6].join("\n"))
/*
Syntax error: Undefined variable: "$bork".
        on line 2 of #{template_loc('bork1')}

1: bork
2:   :bork $bork
CSS
    end
    File.delete(tempfile_loc('bork1'))
  end

  def test_nonfull_exception_handling
    old_full_exception = Sass::Plugin.options[:full_exception]
    Sass::Plugin.options[:full_exception] = false

    File.delete(tempfile_loc('bork1'))
    assert_raise(Sass::SyntaxError) {update_all_stylesheets!}
  ensure
    Sass::Plugin.options[:full_exception] = old_full_exception
  end
  
  def test_two_template_directories
    set_plugin_opts :template_location => {
      template_loc => tempfile_loc,
      template_loc(nil,'more_') => tempfile_loc(nil,'more_')
    }
    update_all_stylesheets!
    ['more1', 'more_import'].each { |name| assert_renders_correctly(name, :prefix => 'more_') }
  end

  def test_two_template_directories_with_line_annotations
    set_plugin_opts :line_comments => true,
                    :style => :nested,
                    :template_location => {
                      template_loc => tempfile_loc,
                      template_loc(nil,'more_') => tempfile_loc(nil,'more_')
                    }
    update_all_stylesheets!
    assert_renders_correctly('more1_with_line_comments', 'more1', :prefix => 'more_')
  end

  def test_doesnt_render_partials
    assert !File.exists?(tempfile_loc('_partial'))
  end

  def test_template_location_array
    assert_equal [[template_loc, tempfile_loc]], Sass::Plugin.template_location_array
  end

  def test_add_template_location
    Sass::Plugin.add_template_location(template_loc(nil, "more_"), tempfile_loc(nil, "more_"))
    assert_equal(
      [[template_loc, tempfile_loc], [template_loc(nil, "more_"), tempfile_loc(nil, "more_")]],
      Sass::Plugin.template_location_array)

    touch 'more1', 'more_'
    touch 'basic'
    assert_needs_update "more1", "more_"
    assert_needs_update "basic"
    update_all_stylesheets!
    assert_doesnt_need_update "more1", "more_"
    assert_doesnt_need_update "basic"
  end

  def test_remove_template_location
    Sass::Plugin.add_template_location(template_loc(nil, "more_"), tempfile_loc(nil, "more_"))
    Sass::Plugin.remove_template_location(template_loc, tempfile_loc)
    assert_equal(
      [[template_loc(nil, "more_"), tempfile_loc(nil, "more_")]],
      Sass::Plugin.template_location_array)

    touch 'more1', 'more_'
    touch 'basic'
    assert_needs_update "more1", "more_"
    assert_needs_update "basic"
    update_all_stylesheets!
    assert_doesnt_need_update "more1", "more_"
    assert_needs_update "basic"
  end

  # Callbacks

  def test_updating_stylesheets_callback
    # Should run even when there's nothing to update
    assert_callback :updating_stylesheets, []
  end

  def test_updating_stylesheets_callback_with_individual_files
    files = [[template_loc("basic"), tempfile_loc("basic")]]
    assert_callback(:updating_stylesheets, files) {Haml::Util.silence_haml_warnings{Sass::Plugin.update_stylesheets(files)}}
  end

  def test_updating_stylesheets_callback_with_never_update
    Sass::Plugin.options[:never_update] = true
    assert_no_callback :updating_stylesheets
  end

  def test_updating_stylesheet_callback_for_updated_template
    Sass::Plugin.options[:always_update] = false
    touch 'basic'
    assert_no_callback :updating_stylesheet, template_loc("complex"), tempfile_loc("complex") do
      assert_callbacks(
        [:updating_stylesheet, template_loc("basic"), tempfile_loc("basic")],
        [:updating_stylesheet, template_loc("import"), tempfile_loc("import")])
    end
  end

  def test_updating_stylesheet_callback_for_fresh_template
    Sass::Plugin.options[:always_update] = false
    assert_no_callback :updating_stylesheet
  end

  def test_updating_stylesheet_callback_for_error_template
    Sass::Plugin.options[:always_update] = false
    touch 'bork1'
    assert_no_callback :updating_stylesheet
  end

  def test_not_updating_stylesheet_callback_for_fresh_template
    Sass::Plugin.options[:always_update] = false
    assert_callback :not_updating_stylesheet, template_loc("basic"), tempfile_loc("basic")
  end

  def test_not_updating_stylesheet_callback_for_updated_template
    Sass::Plugin.options[:always_update] = false
    assert_callback :not_updating_stylesheet, template_loc("complex"), tempfile_loc("complex") do
      assert_no_callbacks(
        [:updating_stylesheet, template_loc("basic"), tempfile_loc("basic")],
        [:updating_stylesheet, template_loc("import"), tempfile_loc("import")])
    end
  end

  def test_not_updating_stylesheet_callback_with_never_update
    Sass::Plugin.options[:never_update] = true
    assert_no_callback :not_updating_stylesheet
  end

  def test_not_updating_stylesheet_callback_for_partial
    Sass::Plugin.options[:always_update] = false
    assert_no_callback :not_updating_stylesheet, template_loc("_partial"), tempfile_loc("_partial")
  end

  def test_not_updating_stylesheet_callback_for_error
    Sass::Plugin.options[:always_update] = false
    touch 'bork1'
    assert_no_callback :not_updating_stylesheet, template_loc("bork1"), tempfile_loc("bork1")
  end

  def test_compilation_error_callback
    Sass::Plugin.options[:always_update] = false
    touch 'bork1'
    assert_callback(:compilation_error,
      lambda {|e| e.message == 'Undefined variable: "$bork".'},
      template_loc("bork1"), tempfile_loc("bork1"))
  end

  def test_compilation_error_callback_for_file_access
    Sass::Plugin.options[:always_update] = false
    assert_callback(:compilation_error,
      lambda {|e| e.is_a?(Errno::ENOENT)},
      template_loc("nonexistent"), tempfile_loc("nonexistent")) do
      Sass::Plugin.update_stylesheets([[template_loc("nonexistent"), tempfile_loc("nonexistent")]])
    end
  end

  def test_creating_directory_callback
    Sass::Plugin.options[:always_update] = false
    dir = File.join(tempfile_loc, "subdir", "nested_subdir")
    FileUtils.rm_r dir
    assert_callback :creating_directory, dir
  end

  ## Regression

  def test_cached_dependencies_update
    FileUtils.mv(template_loc("basic"), template_loc("basic", "more_"))
    set_plugin_opts :load_paths => [result_loc, template_loc(nil, "more_")]

    touch 'basic', 'more_'
    assert_needs_update "import"
    update_all_stylesheets!
    assert_renders_correctly("import")
  ensure
    FileUtils.mv(template_loc("basic", "more_"), template_loc("basic"))
  end

 private

  def assert_renders_correctly(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    prefix = options[:prefix]
    result_name = arguments.shift
    tempfile_name = arguments.shift || result_name

    expected_str = File.read(result_loc(result_name, prefix))
    actual_str = File.read(tempfile_loc(tempfile_name, prefix))
    unless Haml::Util.ruby1_8?
      expected_str = expected_str.force_encoding('IBM866') if result_name == 'import_charset_ibm866'
      actual_str = actual_str.force_encoding('IBM866') if tempfile_name == 'import_charset_ibm866'
    end
    expected_lines = expected_str.split("\n")
    actual_lines = actual_str.split("\n")

    if actual_lines.first == "/*" && expected_lines.first != "/*"
      assert(false, actual_lines[0..Haml::Util.enum_with_index(actual_lines).find {|l, i| l == "*/"}.last].join("\n"))
    end

    expected_lines.zip(actual_lines).each_with_index do |pair, line|
      message = "template: #{result_name}\nline:     #{line + 1}"
      assert_equal(pair.first, pair.last, message)
    end
    if expected_lines.size < actual_lines.size
      assert(false, "#{actual_lines.size - expected_lines.size} Trailing lines found in #{tempfile_name}.css: #{actual_lines[expected_lines.size..-1].join('\n')}")
    end
  end

  def assert_stylesheet_updated(name)
    assert_doesnt_need_update name

    # Make sure it isn't an exception
    expected_lines = File.read(result_loc(name)).split("\n")
    actual_lines = File.read(tempfile_loc(name)).split("\n")
    if actual_lines.first == "/*" && expected_lines.first != "/*"
      assert(false, actual_lines[0..actual_lines.enum_with_index.find {|l, i| l == "*/"}.last].join("\n"))
    end
  end

  def assert_callback(name, *expected_args)
    run = false
    Sass::Plugin.send("on_#{name}") do |*args|
      run ||= expected_args.zip(args).all? do |ea, a|
        ea.respond_to?(:call) ? ea.call(a) : ea == a
      end
    end

    if block_given?
      yield
    else
      update_all_stylesheets!
    end

    assert run, "Expected #{name} callback to be run with arguments:\n  #{expected_args.inspect}"
  end

  def assert_no_callback(name, *unexpected_args)
    Sass::Plugin.send("on_#{name}") do |*a|
      next unless unexpected_args.empty? || a == unexpected_args

      msg = "Expected #{name} callback not to be run"
      if !unexpected_args.empty?
        msg << " with arguments #{unexpected_args.inspect}"
      elsif !a.empty?
        msg << ",\n  was run with arguments #{a.inspect}"
      end

      flunk msg
    end

    if block_given?
      yield
    else
      update_all_stylesheets!
    end
  end

  def assert_callbacks(*args)
    return update_all_stylesheets! if args.empty?
    assert_callback(*args.pop) {assert_callbacks(*args)}
  end

  def assert_no_callbacks(*args)
    return update_all_stylesheets! if args.empty?
    assert_no_callback(*args.pop) {assert_no_callbacks(*args)}
  end

  def clear_callbacks
    Sass::Plugin.instance_variable_set('@_sass_callbacks', {})
  end

  def update_all_stylesheets!
    Haml::Util.silence_haml_warnings do
      Sass::Plugin.update_stylesheets
    end
  end

  def assert_needs_update(*args)
    assert(Sass::Plugin::StalenessChecker.stylesheet_needs_update?(tempfile_loc(*args), template_loc(*args)),
      "Expected #{template_loc(*args)} to need an update.")
  end

  def assert_doesnt_need_update(*args)
    assert(!Sass::Plugin::StalenessChecker.stylesheet_needs_update?(tempfile_loc(*args), template_loc(*args)),
      "Expected #{template_loc(*args)} not to need an update.")
  end

  def touch(*args)
    FileUtils.touch(template_loc(*args))
  end

  def reset_mtimes
    Sass::Plugin::StalenessChecker.dependencies_cache = {}
    atime = Time.now
    mtime = Time.now - 5
    Dir["{#{template_loc},#{tempfile_loc}}/**/*.{css,sass,scss}"].each {|f| File.utime(atime, mtime, f)}
  end

  def template_loc(name = nil, prefix = nil)
    if name
      scss = absolutize "#{prefix}templates/#{name}.scss"
      File.exists?(scss) ? scss : absolutize("#{prefix}templates/#{name}.sass")
    else
      absolutize "#{prefix}templates"
    end
  end

  def tempfile_loc(name = nil, prefix = nil)
    if name
      absolutize "#{prefix}tmp/#{name}.css"
    else
      absolutize "#{prefix}tmp"
    end
  end

  def result_loc(name = nil, prefix = nil)
    if name
      absolutize "#{prefix}results/#{name}.css"
    else
      absolutize "#{prefix}results"
    end
  end

  def absolutize(file)
    "#{File.dirname(__FILE__)}/#{file}"
  end

  def set_plugin_opts(overrides = {})
    Sass::Plugin.options = {
      :template_location => template_loc,
      :css_location => tempfile_loc,
      :style => :compact,
      :load_paths => [result_loc],
      :always_update => true,
      :never_update => false,
    }.merge(overrides)
  end
end

class Sass::Engine
  alias_method :old_render, :render

  def render
    raise "bork bork bork!" if @template[0] == "{bork now!}"
    old_render
  end
end
