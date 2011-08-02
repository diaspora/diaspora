require File.dirname(__FILE__) + '/test_helper'

class TestCodeCoverageAnalyzer < Test::Unit::TestCase
  LINES = <<-EOF.split "\n"
puts 1
if foo
  bar
  baz
end
5.times do
  foo
  bar if baz
end
EOF

  def setup
    if defined? Rcov::Test::Temporary
      Rcov::Test::Temporary.constants.each do |name|
        Rcov::Test::Temporary.module_eval{ remove_const(name) }
      end
    end
  end

  def test_refine_coverage_info
    analyzer = Rcov::CodeCoverageAnalyzer.new
    cover = [1, 1, nil, nil, 0, 5, 5, 5, 0]
    line_info, marked_info,
      count_info = analyzer.instance_eval{ refine_coverage_info(LINES, cover) }
    assert_equal(LINES, line_info)
    assert_equal([true] * 2 + [false] * 3 + [true] * 3 + [false], marked_info)
    assert_equal([1, 1, 0, 0, 0, 5, 5, 5, 0], count_info)
  end

  def test_analyzed_files_no_analysis
    analyzer = Rcov::CodeCoverageAnalyzer.new
    assert_equal([], analyzer.analyzed_files)
  end

  def test_raw_coverage_info
    sample_file = File.join(File.dirname(__FILE__), "assets/sample_01.rb")
    lines = File.readlines(sample_file)
    analyzer = Rcov::CodeCoverageAnalyzer.new
    analyzer.run_hooked{ load sample_file }

    assert_equal(lines, SCRIPT_LINES__[sample_file][0, lines.size])
    assert(analyzer.analyzed_files.include?(sample_file))
    line_info, cov_info, count_info = analyzer.data(sample_file)
    assert_equal(lines, line_info)
    assert_equal([true, true, false, false, true, false, true], cov_info)
    assert_equal([1, 2, 0, 0, 1, 0, 11], count_info) unless RUBY_PLATFORM =~ /java/
    # JRUBY reports an if x==blah as hitting this type of line once, JRUBY also optimizes this stuff so you'd have to run with --debug to get "extra" information.  MRI hits it twice.
    assert_equal([1, 3, 0, 0, 1, 0, 13], count_info) if RUBY_PLATFORM =~ /java/
    analyzer.reset
    assert_equal(nil, analyzer.data(sample_file))
    assert_equal([], analyzer.analyzed_files)
  end

  def test_script_lines_workaround_detects_correctly
    analyzer = Rcov::CodeCoverageAnalyzer.new
    lines = ["puts a", "foo", "bar"] * 3
    coverage = [true] * 3 + [false] * 6
    counts = [1] * 3 + [0] * 6
    nlines, ncoverage, ncounts = analyzer.instance_eval do
      script_lines_workaround(lines, coverage, counts)
    end

    assert_equal(["puts a", "foo", "bar"], nlines)
    assert_equal([true, true, true], ncoverage)
    assert_equal([1, 1, 1], ncounts)
  end

  def test_script_lines_workaround_no_false_positives
    analyzer = Rcov::CodeCoverageAnalyzer.new
    lines = ["puts a", "foo", "bar"] * 2 + ["puts a", "foo", "baz"]
    coverage = [true] * 9
    counts = [1] * 9
    nlines, ncoverage, ncounts = analyzer.instance_eval do
      script_lines_workaround(lines, coverage, counts)
    end
    assert_equal(lines, nlines)
    assert_equal(coverage, ncoverage)
    assert_equal(counts, ncounts)
  end

  def test_if_elsif_reports_correctly
    sample_file = File.join(File.dirname(__FILE__), "assets/sample_06.rb")
    lines = File.readlines(sample_file)
    analyzer = Rcov::CodeCoverageAnalyzer.new
    analyzer.run_hooked{ load sample_file }
    assert_equal(lines, SCRIPT_LINES__[sample_file][0, lines.size])
    assert(analyzer.analyzed_files.include?(sample_file))
    line_info, cov_info, count_info = analyzer.data(sample_file)
    assert_equal(lines, line_info)
    assert_equal([true, true, false, true, true, false, false, false], cov_info) unless RUBY_PLATFORM == "java"
  end

  def test_differential_coverage_data
    sample_file = File.join(File.dirname(__FILE__), "assets/sample_01.rb")
    lines = File.readlines(sample_file)
    analyzer = Rcov::CodeCoverageAnalyzer.new
    analyzer.run_hooked{ load sample_file }
    line_info, cov_info, count_info = analyzer.data(sample_file)
    assert_equal([1, 2, 0, 0, 1, 0, 11], count_info) if RUBY_VERSION =~ /1.9/

    analyzer.reset
    #set_trace_func proc { |event, file, line, id, binding, classname| printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname if (file =~ /sample_02.rb/) }     

    sample_file = File.join(File.dirname(__FILE__), "assets/sample_02.rb")
    analyzer.run_hooked{ load sample_file }
    line_info, cov_info, count_info = analyzer.data(sample_file)
    if RUBY_PLATFORM == "java"
      assert_equal([8, 3, 0, 0, 0], count_info) 
    else
      assert_equal([8, 1, 0, 0, 0], count_info) unless  RUBY_VERSION =~ /1.9/
      assert_equal([4, 1, 0, 0, 4], count_info) if RUBY_VERSION =~ /1.9/
    end

    analyzer.reset
    assert_equal([], analyzer.analyzed_files)
    analyzer.run_hooked{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
    line_info, cov_info, count_info = analyzer.data(sample_file)
    if RUBY_PLATFORM == "java"
      assert_equal([0, 1, 3, 1, 0], count_info) unless RUBY_VERSION =~ /1.9/
    else
      assert_equal([0, 1, 1, 1, 0], count_info) unless RUBY_VERSION =~ /1.9/
      assert_equal([0, 2, 1, 0, 0], count_info) if RUBY_VERSION =~ /1.9/
    end
    analyzer.run_hooked do
      10.times{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
    end
    line_info, cov_info, count_info = analyzer.data(sample_file)
    assert_equal([0, 11, 33, 11, 0], count_info) if RUBY_PLATFORM == "java"
    assert_equal([0, 11, 11, 11, 0], count_info) unless RUBY_PLATFORM == "java"
    10.times{ analyzer.run_hooked{ Rcov::Test::Temporary::Sample02.foo(1, 1) } }
    line_info, cov_info, count_info = analyzer.data(sample_file)
    assert_equal([0, 21, 63, 21, 0], count_info) if RUBY_PLATFORM == "java"
    assert_equal([0, 21, 21, 21, 0], count_info) unless RUBY_PLATFORM == "java"

    count_info2 = nil
    10.times do |i|
      analyzer.run_hooked do
        Rcov::Test::Temporary::Sample02.foo(1, 1)
        line_info, cov_info, count_info = analyzer.data(sample_file) if i == 3
        line_info2, cov_info2, count_info2 = analyzer.data(sample_file)
      end
    end
    if RUBY_PLATFORM == "java"
      assert_equal([0, 25, 75, 25, 0], count_info)
      assert_equal([0, 31, 93, 31, 0], count_info2)
    else
      assert_equal([0, 25, 25, 25, 0], count_info)
      assert_equal([0, 31, 31, 31, 0], count_info2)
    end
  end

  def test_nested_analyzer_blocks
    a1 = Rcov::CodeCoverageAnalyzer.new
    a2 = Rcov::CodeCoverageAnalyzer.new

    sample_file = File.join(File.dirname(__FILE__), "assets/sample_02.rb")
    load sample_file

    a1.run_hooked do
      100.times{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
      a2.run_hooked do
        10.times{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
      end
      100.times{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
    end

    a2.run_hooked do
      100.times{ Rcov::Test::Temporary::Sample02.foo(1, 1) }
      10.times{ a1.run_hooked { Rcov::Test::Temporary::Sample02.foo(1, 1) } }
    end

    a1.install_hook
    Rcov::Test::Temporary::Sample02.foo(1, 1)
    a1.remove_hook

    a2.install_hook
    Rcov::Test::Temporary::Sample02.foo(1, 1)
    a2.remove_hook

    _, _, counts1 = a1.data(sample_file)
    _, _, counts2 = a2.data(sample_file)
    if RUBY_PLATFORM == "java"
      assert_equal([0, 221, 663, 221, 0], counts1)    
      assert_equal([0, 121, 363, 121, 0], counts2)
    else
      assert_equal([0, 221, 221, 221, 0], counts1)
      assert_equal([0, 121, 121, 121, 0], counts2)
    end
  end
  

  def test_reset
    a1 = Rcov::CodeCoverageAnalyzer.new

    sample_file = File.join(File.dirname(__FILE__), "assets/sample_02.rb")
    load sample_file
    
    a1.run_hooked do
      100.times do |i|
        Rcov::Test::Temporary::Sample02.foo(1, 1)
        a1.reset if i == 49
      end
    end

    assert_equal([0, 50, 50, 50, 0], a1.data(sample_file)[2]) unless RUBY_PLATFORM == "java"
    assert_equal([0, 50, 150, 50, 0], a1.data(sample_file)[2]) if RUBY_PLATFORM == "java"
  end

  def test_compute_raw_difference
    first = {"a" => [1,1,1,1,1]}
    last =  {"a" => [2,1,5,2,1], "b" => [1,2,3,4,5]}
    a = Rcov::CodeCoverageAnalyzer.new
    assert_equal({"a" => [1,0,4,1,0], "b" => [1,2,3,4,5]},
                 a.instance_eval{ compute_raw_data_difference(first, last)} )
  end
end
