require File.dirname(__FILE__) + '/test_helper'

=begin
Updating functional testdata automatically is DANGEROUS, so I do manually.

== update functional test
cd ~/src/rcov/test
rcov="ruby ../bin/rcov -I../lib:../ext/rcovrt -o expected_coverage"

$rcov -a sample_04.rb
$rcov sample_04.rb
$rcov --gcc --include-file=sample --exclude=rcov sample_04.rb > expected_coverage/gcc-text.out

cp sample_05-old.rb sample_05.rb
$rcov --no-html --gcc --include-file=sample --exclude=rcov --save=coverage.info sample_05.rb > expected_coverage/diff-gcc-original.out
cp sample_05-new.rb sample_05.rb
$rcov --no-html --gcc -D --include-file=sample --exclude=rcov sample_05.rb > expected_coverage/diff-gcc-diff.out
$rcov --no-html -D --include-file=sample --exclude=rcov sample_05.rb > expected_coverage/diff.out
$rcov --no-html --no-color -D --include-file=sample --exclude=rcov sample_05.rb > expected_coverage/diff-no-color.out
$rcov --no-html --gcc --include-file=sample --exclude=rcov sample_05.rb > expected_coverage/diff-gcc-all.out

=end

class TestFunctional < Test::Unit::TestCase
  @@dir = Pathname(__FILE__).expand_path.dirname

  def strip_variable_sections(str)
    str.sub(/Generated on.+$/, '').sub(/Generated using the.+$/, '').squeeze("\n")
  end

  def cmp(file)
    content = lambda{|dir| strip_variable_sections(File.read(@@dir+dir+file))}

    assert_equal(content["expected_coverage"], content["actual_coverage"])
  end

  def with_testdir(&block)
    Dir.chdir(@@dir, &block)
  end

  def run_rcov(opts, script="assets/sample_04.rb", opts_tail="")
    rcov = @@dir+"../bin/rcov"
    ruby_opts = "-I../lib:../ext/rcovrt"
    ruby = "ruby"
    ruby = "jruby" if RUBY_PLATFORM =~ /java/
    with_testdir do
      `cd #{@@dir}; #{ruby} #{ruby_opts} #{rcov} #{opts} -o actual_coverage #{script} #{opts_tail}`
      yield if block_given?
    end
  end

  def test_annotation
    run_rcov("-a") do
      cmp "../assets/sample_04.rb"
      cmp "../assets/sample_03.rb"
    end
  end

  @@selection = "--include-file=sample --exclude=rcov"
  def test_text_gcc
    run_rcov("--gcc #{@@selection}", "assets/sample_04.rb", "> actual_coverage/gcc-text.out") do
      cmp "gcc-text.out"
    end
  end

  def test_diff
    with_testdir { FileUtils.cp "assets/sample_05-old.rb", "assets/sample_05.rb" }

    run_rcov("--no-html --gcc #{@@selection} --save=coverage.info", "assets/sample_05.rb", "> actual_coverage/diff-gcc-original.out") do
      cmp "diff-gcc-original.out"
    end

    with_testdir { FileUtils.cp "assets/sample_05-new.rb", "assets/sample_05.rb" }
    run_rcov("--no-html -D --gcc #{@@selection}", "assets/sample_05.rb", "> actual_coverage/diff-gcc-diff.out") do
      cmp "diff-gcc-diff.out"
    end

    run_rcov("--no-html -D #{@@selection}", "assets/sample_05.rb", "> actual_coverage/diff.out") do
      cmp "diff.out"
    end

    run_rcov("--no-html --no-color -D #{@@selection}", "assets/sample_05.rb", "> actual_coverage/diff-no-color.out") do
      cmp "diff-no-color.out"
    end

    run_rcov("--no-html --gcc #{@@selection}", "assets/sample_05.rb", "> actual_coverage/diff-gcc-all.out") do
      cmp "diff-gcc-all.out"
    end  
  end
  
end
