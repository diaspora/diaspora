require File.dirname(__FILE__) + '/test_helper'

class TestFileStatistics < Test::Unit::TestCase
  def test_trailing_end_is_inferred
    verify_everything_marked "trailing end", <<-EOF
      1 class X
      1   def foo
      2     "foo"
      0   end
      0 end
    EOF
    verify_everything_marked "trailing end with comments", <<-EOF
      1 class X
      1   def foo
      2     "foo"
      0   end
      0 # foo bar
      0 =begin
      0  ....
      0 =end
      0 end
    EOF
  end

  def test_begin_ensure_else_case_are_inferred
    verify_everything_marked "begin ensure else case", <<-EOF
      0 begin
      #   bleh
      2   puts a
      0   begin
      2     raise "foo"
      0   rescue Exception => e
      2     puts b
      0   ensure
      2     puts c
      0   end
      2   if a()
      1     b
      0   else
      1     c
      0   end
      0   case
      2   when bar =~ /foo/
      1     puts "bar"
      0   else
      1     puts "baz"
      0   end
      0 end
    EOF
  end

  def test_rescue_is_inferred
    verify_everything_marked "rescue", <<-EOF
      0 begin
      1   foo
      0 rescue
      1   puts "bar"
      0 end
    EOF
  end

  def test_code_metrics_are_computed_correctly
    lines, coverage, counts = code_info_from_string <<-EOF
      1 a = 1
      0 # this is a comment
      1 if bar
      0   b = 2
      0 end
      0 =begin
      0 this too
      0 bleh
      0 =end
      0 puts <<EOF
      0  bleh
      0 EOF
      3 c.times{ i += 1}
    EOF
    sf = Rcov::FileStatistics.new("metrics", lines, counts)
    assert_in_delta(0.307, sf.total_coverage, 0.01)
    assert_in_delta(0.375, sf.code_coverage, 0.01)
    assert_equal(8, sf.num_code_lines)
    assert_equal(13, sf.num_lines)
    assert_equal([true, :inferred, true, false, false, false, false, false,
                 false, false, false, false, true], sf.coverage.to_a)
  end

  def test_merge
    lines, coverage, counts = code_info_from_string <<-EOF
      1 a = 1
      1 if bar
      0   b = 2
      0 end
      1 puts <<EOF
      0  bleh
      0 EOF
      3 c.times{ i += 1}
    EOF
    sf = Rcov::FileStatistics.new("merge", lines, counts)
    lines, coverage, counts = code_info_from_string <<-EOF
      1 a = 1
      1 if bar
      1   b = 2
      0 end
      1 puts <<EOF
      0  bleh
      0 EOF
      10 c.times{ i += 1}
    EOF
    sf2 = Rcov::FileStatistics.new("merge", lines, counts)
    expected = [true, true, true, :inferred, true, :inferred, :inferred, true]
    assert_equal(expected, sf2.coverage.to_a)
    sf.merge(sf2.lines, sf2.coverage, sf2.counts)
    assert_equal(expected, sf.coverage.to_a)
    assert_equal([2, 2, 1, 0, 2, 0, 0, 13], sf.counts)
  end

  def test_last_comment_block_is_marked
    verify_everything_marked "last comment block", <<-EOF
      1 a = 1
      1 b = 1
      0 # foo
      0 # bar baz
    EOF
    verify_everything_marked "last comment block, =begin/=end", <<-EOF
      1 a = 1
      2 b = 1
      0 # fooo
      0 =begin
      0  bar baz
      0 =end
    EOF
    verify_everything_marked "last comment block, __END__", <<-EOF
      1 a = 1
      2 b = 1
      0 # fooo
      0 =begin
      0  bar baz
      0 =end
      __END__
    EOF
  end

  def test_heredocs_basic
    verify_everything_marked "heredocs-basic.rb", <<-EOF
      1 puts 1 + 1
      1 puts <<HEREDOC
      0   first line of the heredoc
      0   not marked
      0   but should be
      0 HEREDOC
      1 puts 1
    EOF
    verify_everything_marked "squote", <<-EOF
      1 puts <<'HEREDOC'
      0   first line of the heredoc
      0 HEREDOC
    EOF
    verify_everything_marked "dquote", <<-EOF
      1 puts <<"HEREDOC"
      0   first line of the heredoc
      0 HEREDOC
    EOF
    verify_everything_marked "xquote", <<-EOF
      1 puts <<`HEREDOC`
      0   first line of the heredoc
      0 HEREDOC
    EOF
    verify_everything_marked "stuff-after-heredoc", <<-EOF
      1 full_message = build_message(msg, <<EOT, object1, object2)
      0 <?> and <?> do not contain the same elements
      0 EOT
    EOF
  end

  def test_heredocs_multiple
    verify_everything_marked "multiple-unquoted", <<-EOF
      1 puts <<HEREDOC, <<HERE2
      0   first line of the heredoc
      0 HEREDOC
      0   second heredoc
      0 HERE2
    EOF
    verify_everything_marked "multiple-quoted", <<-EOF
      1 puts <<'HEREDOC', <<`HERE2`, <<"HERE3"
      0   first line of the heredoc
      0 HEREDOC
      0   second heredoc
      0 HERE2
      0 dsfdsfffd
      0 HERE3
    EOF
    verify_everything_marked "same-identifier", <<-EOF
      1 puts <<H, <<H
      0 foo
      0 H
      0 bar
      0 H
    EOF
    verify_everything_marked "stuff-after-heredoc", <<-EOF
      1 full_message = build_message(msg, <<EOT, object1, object2, <<EOT)
      0 <?> and <?> do not contain the same elements
      0 EOT
      0 <?> and <?> are foo bar baz
      0 EOT
    EOF
  end
  def test_ignore_non_heredocs
    verify_marked_exactly "bitshift-numeric", [0], <<-EOF
      1 puts 1<<2
      0 return if foo
      0 do_stuff()
      0 2
    EOF
    verify_marked_exactly "bitshift-symbolic", [0], <<-EOF
      1 puts 1<<LSHIFT
      0 return if bar
      0 do_stuff()
      0 LSHIFT
    EOF
    verify_marked_exactly "bitshift-symbolic-multi", 0..3, <<-EOF
      1 puts <<EOF, 1<<LSHIFT
      0 random text
      0 EOF
      1 return if bar
      0 puts "foo"
      0 LSHIFT
    EOF
    verify_marked_exactly "bitshift-symshift-evil", 0..2, <<-EOF
      1 foo = 1
      1 puts foo<<CONS
      1 return if bar
      0 foo + baz
    EOF
  end

  def test_heredocs_with_interpolation_alone_in_method
    verify_everything_marked "lonely heredocs with interpolation", <<-'EOS'
      1 def to_s
      0  <<-EOF
      1    #{name}
      0    #{street}
      0    #{city}, #{state}
      0    #{zip}
      0  EOF
      0 end
    EOS
  end

  def test_handle_multiline_expressions
    verify_everything_marked "expression", <<-EOF
      1 puts 1, 2.
      0           abs +
      0           1 -
      0           1 *
      0           1 /
      0           1, 1 <
      0           2, 3 >
      0           4 %
      0           3 &&
      0           true ||
      0           foo <<
      0           bar(
      0               baz[
      0                   {
      0                    1,2}] =
      0               1 )
    EOF
    verify_everything_marked "boolean expression", <<-EOF
      1 x = (foo and
      0         bar) or
      0     baz
    EOF
    verify_marked_exactly "code blocks", [0, 3, 6], <<-EOF
      1 x = foo do   # stuff
      0   baz
      0 end
      1 bar do |x|
      0   baz
      0 end
      1 bar {|a, b|    # bleh | +1
      0   baz
      0 }
    EOF
    verify_everything_marked "escaped linebreaks", <<-EOF
      1 def t2
      0    puts \\
      1      "foo"
      0  end
      0 end
    EOF
  end

  def test_handle_multiline_blocks_first_not_marked
    verify_everything_marked "multiline block first not marked", <<-'EOF'
      1 blah = Array.new
      1 10.times do
      0   blah << lambda do |f|
      1     puts "I should say #{f}!"
      0   end
      0 end
    EOF
  end

  def test_handle_multiline_blocks_last_line_not_marked
    verify_everything_marked "multiline block last not marked", <<-'EOF'
      1 blee = [1, 2, 3]
      0 blee.map! do |e|
      1   [e, e]
      0 end.flatten!
      1 p blee
    EOF
  end

  def test_handle_multiline_data_with_trailing_stuff_on_last_line
    verify_everything_marked "multiline data hash", <<-'EOF'
      1    @review = Review.new({
      0      :product_id => params[:id],
      0      :user       => current_user
      0    }.merge(params[:review]))      #red
      1    @review.save
    EOF
  end

  def test_handle_multiline_expression_1st_line_ends_in_block_header
    # excerpt taken from mongrel/handlers.rb
    verify_everything_marked "multiline with block starting on 1st", <<-EOF
    1 uris = listener.classifier.handler_map
    0 results << table("handlers", uris.map {|uri,handlers|
    1  [uri,
    0    "<pre>" +
    1    handlers.map {|h| h.class.to_s }.join("\n") +
    0    "</pre>"
    0  ]
    1 })
    EOF
  end

  def test_handle_multiple_block_end_delimiters_in_empty_line
    verify_everything_marked "multiline with }) delimiter, forward", <<-EOF
      1 assert(@c.config == {
      0 'host' => 'myhost.tld',
      0 'port' => 1234
      0 })
    EOF
    verify_everything_marked "multiline with }) delimiter, backwards", <<-EOF
      0 assert(@c.config == {
      0 'host' => 'myhost.tld',
      0 'port' => 1234
      1 })
    EOF
  end

  STRING_DELIMITER_PAIRS = [
    %w-%{ }-, %w-%q{ }-, %w-%Q{ }-, %w{%[ ]}, %w{%q[ ]},
    %w{%( )}, %w{%Q( )}, %w{%Q[ ]}, %w{%q! !}, %w{%! !},
  ]

  def test_multiline_strings_basic
    STRING_DELIMITER_PAIRS.each do |s_delim, e_delim|
      verify_everything_marked "multiline strings, basic #{s_delim}", <<-EOF
        1 PATTERN_TEXT = #{s_delim}
        0   NUMBERS       = 'one|two|three|four|five'
        0   ON_OFF        = 'on|off'
        0 #{e_delim}
      EOF
    end
    STRING_DELIMITER_PAIRS.each do |s_delim, e_delim|
      verify_marked_exactly "multiline strings, escaped #{s_delim}", [0], <<-EOF
        1 PATTERN_TEXT = #{s_delim} foooo bar baz \\#{e_delim} baz #{e_delim}
        0 NUMBERS       = 'one|two|three|four|five'
        0 ON_OFF        = 'on|off'
      EOF

      verify_marked_exactly "multiline strings, #{s_delim}, interpolation",
                            [0], <<-EOF
        1 PATTERN_TEXT = #{s_delim}  \#{#{s_delim} foo #{e_delim}} \\#{e_delim} baz #{e_delim}
        0 NUMBERS       = 'one|two|three|four|five'
        0 ON_OFF        = 'on|off'
      EOF
    end
  end

  def test_multiline_strings_escaped_delimiter
    STRING_DELIMITER_PAIRS.each do |s_delim, e_delim|
      verify_everything_marked "multiline, escaped #{s_delim}", <<-EOF
        1 PATTERN_TEXT = #{s_delim}  foo \\#{e_delim}
        0   NUMBERS       = 'one|two|three|four|five'
        0   ON_OFF        = 'on|off'
        0 #{e_delim}
      EOF
    end
  end

  def test_handle_multiline_expressions_with_heredocs
    verify_everything_marked "multiline and heredocs", <<-EOF
      1 puts <<EOF +
      0 testing
      0 one two three
      0 EOF
      0 somevar
    EOF
  end

  def test_begin_end_comment_blocks
    verify_everything_marked "=begin/=end", <<-EOF
    1 x = foo
    0 =begin
    0 return if bar(x)
    0 =end
    1 y = 1
    EOF
  end

  def test_is_code_p
    verify_is_code "basic", [true] + [false] * 5 + [true], <<-EOF
    1 x = foo
    0 =begin
    0 return if bar
    0 =end
    0 # foo
    0 # bar
    1 y = 1
    EOF
  end

  def test_is_code_p_tricky_heredocs
    verify_is_code "tricky heredocs", [true] * 4, <<-EOF
    2 x = foo <<EOF and return
    0 =begin
    0 EOF
    0 z = x + 1
    EOF
  end

  def verify_is_code(testname, is_code_arr, str)
    lines, coverage, counts = code_info_from_string str

    sf = Rcov::FileStatistics.new(testname, lines, counts)
    is_code_arr.each_with_index do |val,i|
      assert_equal(val, sf.is_code?(i),
                   "Unable to detect =begin comments properly: #{lines[i].inspect}")
    end
  end

  def verify_marked_exactly(testname, marked_indices, str)
    lines, coverage, counts = code_info_from_string(str)

    sf = Rcov::FileStatistics.new(testname, lines, counts)
    lines.size.times do |i|
      if marked_indices.include? i
        assert(sf.coverage[i], "Test #{testname}; " +
               "line should have been marked: #{lines[i].inspect}.")
      else
        assert(!sf.coverage[i], "Test #{testname}; " +
               "line should not have been marked: #{lines[i].inspect}.")
      end
    end
  end

  def verify_everything_marked(testname, str)
    verify_marked_exactly(testname, (0...str.size).to_a, str)
  end


  def code_info_from_string(str)
    str = str.gsub(/^\s*/,"")
    [ str.lines.map{|line| line.sub(/^\d+ /, "") },
      str.lines.map{|line| line[/^\d+/].to_i > 0},
      str.lines.map{|line| line[/^\d+/].to_i } ]
  end
end
