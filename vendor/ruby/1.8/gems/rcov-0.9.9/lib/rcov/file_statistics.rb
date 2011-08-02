module Rcov
  # A FileStatistics object associates a filename to:
  # 1. its source code
  # 2. the per-line coverage information after correction using rcov's heuristics
  # 3. the per-line execution counts
  #
  # A FileStatistics object can be therefore be built given the filename, the
  # associated source code, and an array holding execution counts (i.e. how many
  # times each line has been executed).
  #
  # FileStatistics is relatively intelligent: it handles normal comments,
  # <tt>=begin/=end</tt>, heredocs, many multiline-expressions... It uses a
  # number of heuristics to determine what is code and what is a comment, and to
  # refine the initial (incomplete) coverage information.
  #
  # Basic usage is as follows:
  #  sf = FileStatistics.new("foo.rb", ["puts 1", "if true &&", "   false", 
  #                                 "puts 2", "end"],  [1, 1, 0, 0, 0])
  #  sf.num_lines        # => 5
  #  sf.num_code_lines   # => 5
  #  sf.coverage[2]      # => true
  #  sf.coverage[3]      # => :inferred
  #  sf.code_coverage    # => 0.6
  #                    
  # The array of strings representing the source code and the array of execution
  # counts would normally be obtained from a Rcov::CodeCoverageAnalyzer.
  class FileStatistics
    attr_reader :name, :lines, :coverage, :counts
    def initialize(name, lines, counts, comments_run_by_default = false)
      @name = name
      @lines = lines
      initial_coverage = counts.map{|x| (x || 0) > 0 ? true : false }
      @coverage = CoverageInfo.new initial_coverage
      @counts = counts
      @is_begin_comment = nil
      # points to the line defining the heredoc identifier
      # but only if it was marked (we don't care otherwise)
      @heredoc_start = Array.new(lines.size, false)
      @multiline_string_start = Array.new(lines.size, false)
      extend_heredocs
      find_multiline_strings
      precompute_coverage comments_run_by_default
    end

    # Merge code coverage and execution count information.
    # As for code coverage, a line will be considered
    # * covered for sure (true) if it is covered in either +self+ or in the 
    #   +coverage+ array
    # * considered <tt>:inferred</tt> if the neither +self+ nor the +coverage+ array
    #   indicate that it was definitely executed, but it was <tt>inferred</tt>
    #   in either one 
    # * not covered (<tt>false</tt>) if it was uncovered in both
    #
    # Execution counts are just summated on a per-line basis.
    def merge(lines, coverage, counts)
      coverage.each_with_index do |v, idx|
        case @coverage[idx]
        when :inferred 
          @coverage[idx] = v || @coverage[idx]
        when false 
          @coverage[idx] ||= v
        end
      end
      counts.each_with_index{|v, idx| @counts[idx] += v }
      precompute_coverage false
    end

    # Total coverage rate if comments are also considered "executable", given as
    # a fraction, i.e. from 0 to 1.0.
    # A comment is attached to the code following it (RDoc-style): it will be
    # considered executed if the the next statement was executed.
    def total_coverage
      return 0 if @coverage.size == 0
      @coverage.inject(0.0) {|s,a| s + (a ? 1:0) } / @coverage.size
    end

    # Code coverage rate: fraction of lines of code executed, relative to the
    # total amount of lines of code (loc). Returns a float from 0 to 1.0.
    def code_coverage
      indices = (0...@lines.size).select{|i| is_code? i }
      return 0 if indices.size == 0
      count = 0
      indices.each {|i| count += 1 if @coverage[i] }
      1.0 * count / indices.size
    end

    def code_coverage_for_report
      code_coverage * 100
    end

    def total_coverage_for_report
      total_coverage * 100
    end

    # Number of lines of code (loc).
    def num_code_lines
      (0...@lines.size).select{|i| is_code? i}.size
    end

    # Total number of lines.
    def num_lines
      @lines.size
    end

    # Returns true if the given line number corresponds to code, as opposed to a
    # comment (either # or =begin/=end blocks).
    def is_code?(lineno)
      unless @is_begin_comment
        @is_begin_comment = Array.new(@lines.size, false)
        pending = []
        state = :code
        @lines.each_with_index do |line, index|
          case state
          when :code
            if /^=begin\b/ =~ line
              state = :comment
              pending << index
            end
          when :comment
            pending << index
            if /^=end\b/ =~ line
              state = :code
              pending.each{|idx| @is_begin_comment[idx] = true}
              pending.clear
            end
          end
        end
      end
      @lines[lineno] && !@is_begin_comment[lineno] && @lines[lineno] !~ /^\s*(#|$)/ 
    end

    private

    def find_multiline_strings
      state = :awaiting_string
      wanted_delimiter = nil
      string_begin_line = 0
      @lines.each_with_index do |line, i|
        matching_delimiters = Hash.new{|h,k| k} 
        matching_delimiters.update("{" => "}", "[" => "]", "(" => ")")
        case state
        when :awaiting_string
          # very conservative, doesn't consider the last delimited string but
          # only the very first one
          if md = /^[^#]*%(?:[qQ])?(.)/.match(line)
            if !/"%"/.match(line)
              wanted_delimiter = /(?!\\).#{Regexp.escape(matching_delimiters[md[1]])}/
              # check if closed on the very same line
              # conservative again, we might have several quoted strings with the
              # same delimiter on the same line, leaving the last one open
              unless wanted_delimiter.match(md.post_match)
                state = :want_end_delimiter
                string_begin_line = i
              end
            end
          end
        when :want_end_delimiter
          @multiline_string_start[i] = string_begin_line
          if wanted_delimiter.match(line)
            state = :awaiting_string
          end
        end
      end
    end
    
    def is_nocov?(line)
      line =~ /#:nocov:/
    end
    
    def mark_nocov_regions(nocov_line_numbers, coverage)
      while nocov_line_numbers.size > 0
        begin_line, end_line = nocov_line_numbers.shift, nocov_line_numbers.shift
        next unless begin_line && end_line
        (begin_line..end_line).each do |line_num|
          coverage[line_num] ||= :inferred
        end
      end
    end

    def precompute_coverage(comments_run_by_default = true)
      changed = false
      lastidx = lines.size - 1
      if (!is_code?(lastidx) || /^__END__$/ =~ @lines[-1]) && !@coverage[lastidx]
        # mark the last block of comments
        @coverage[lastidx] ||= :inferred
        (lastidx-1).downto(0) do |i|
          break if is_code?(i)
          @coverage[i] ||= :inferred
        end
      end
      nocov_line_numbers = []
      
      (0...lines.size).each do |i|
        nocov_line_numbers << i if is_nocov?(@lines[i])

        next if @coverage[i]
        line = @lines[i]
        if /^\s*(begin|ensure|else|case)\s*(?:#.*)?$/ =~ line && next_expr_marked?(i) or
          /^\s*(?:end|\})\s*(?:#.*)?$/ =~ line && prev_expr_marked?(i) or
          /^\s*(?:end\b|\})/ =~ line && prev_expr_marked?(i) && next_expr_marked?(i) or
          /^\s*rescue\b/ =~ line && next_expr_marked?(i) or
          /(do|\{)\s*(\|[^|]*\|\s*)?(?:#.*)?$/ =~ line && next_expr_marked?(i) or
          prev_expr_continued?(i) && prev_expr_marked?(i) or
          comments_run_by_default && !is_code?(i) or 
          /^\s*((\)|\]|\})\s*)+(?:#.*)?$/ =~ line && prev_expr_marked?(i) or
          prev_expr_continued?(i+1) && next_expr_marked?(i)
          @coverage[i] ||= :inferred
          changed = true
        end
        
      end

      mark_nocov_regions(nocov_line_numbers, @coverage)
      
      (@lines.size-1).downto(0) do |i|
        next if @coverage[i]
        if !is_code?(i) and @coverage[i+1] 
          @coverage[i] = :inferred
          changed = true
        end
      end

      extend_heredocs if changed

      # if there was any change, we have to recompute; we'll eventually
      # reach a fixed point and stop there
      precompute_coverage(comments_run_by_default) if changed
    end

    require 'strscan'
    def extend_heredocs
      i = 0
      while i < @lines.size
        unless is_code? i
          i += 1
          next
        end
        #FIXME: using a restrictive regexp so that only <<[A-Z_a-z]\w*
        # matches when unquoted, so as to avoid problems with 1<<2
        # (keep in mind that whereas puts <<2 is valid, puts 1<<2 is a
        # parse error, but  a = 1<<2  is of course fine)
        scanner = StringScanner.new(@lines[i])
        j = k = i
        loop do
          scanned_text = scanner.search_full(/<<(-?)(?:(['"`])((?:(?!\2).)+)\2|([A-Z_a-z]\w*))/, true, true)
          # k is the first line after the end delimiter for the last heredoc
          # scanned so far
          unless scanner.matched?
            i = k
            break
          end
          term = scanner[3] || scanner[4]
          # try to ignore symbolic bitshifts like  1<<LSHIFT
          ident_text = "<<#{scanner[1]}#{scanner[2]}#{term}#{scanner[2]}"
          if scanned_text[/\d+\s*#{Regexp.escape(ident_text)}/]
            # it was preceded by a number, ignore
            i = k
            break
          end
          must_mark = []
          end_of_heredoc = (scanner[1] == "-") ? /^\s*#{Regexp.escape(term)}$/ : /^#{Regexp.escape(term)}$/
          loop do
            break if j == @lines.size
            must_mark << j
            if end_of_heredoc =~ @lines[j]
              must_mark.each do |n|
                @heredoc_start[n] = i
              end
              if (must_mark + [i]).any?{|lineidx| @coverage[lineidx]}
                @coverage[i] ||= :inferred
                must_mark.each{|lineidx| @coverage[lineidx] ||= :inferred}
              end
              # move the "first line after heredocs" index
              if @lines[j+=1] =~ /^\s*\n$/
                k = j
              end
              break
            end
            j += 1
          end
        end

        i += 1
      end
    end

    def next_expr_marked?(lineno)
      return false if lineno >= @lines.size
      found = false
      idx = (lineno+1).upto(@lines.size-1) do |i|
        next unless is_code? i
        found = true
        break i
      end
      return false unless found
      @coverage[idx]
    end

    def prev_expr_marked?(lineno)
      return false if lineno <= 0
      found = false
      idx = (lineno-1).downto(0) do |i|
        next unless is_code? i
        found = true
        break i
      end
      return false unless found
      @coverage[idx]
    end

    def prev_expr_continued?(lineno)
      return false if lineno <= 0
      return false if lineno >= @lines.size
      found = false
      if @multiline_string_start[lineno] && 
        @multiline_string_start[lineno] < lineno
        return true
      end
      # find index of previous code line
      idx = (lineno-1).downto(0) do |i|
        if @heredoc_start[i]
          found = true
          break @heredoc_start[i] 
        end
        next unless is_code? i
        found = true
        break i
      end
      return false unless found
      #TODO: write a comprehensive list
      if is_code?(lineno) && /^\s*((\)|\]|\})\s*)+(?:#.*)?$/.match(@lines[lineno])
        return true
      end
      #FIXME: / matches regexps too
      # the following regexp tries to reject #{interpolation}
      r = /(,|\.|\+|-|\*|\/|<|>|%|&&|\|\||<<|\(|\[|\{|=|and|or|\\)\s*(?:#(?![{$@]).*)?$/.match @lines[idx]
      # try to see if a multi-line expression with opening, closing delimiters
      # started on that line
      [%w!( )!].each do |opening_str, closing_str| 
        # conservative: only consider nesting levels opened in that line, not
        # previous ones too.
        # next regexp considers interpolation too
        line = @lines[idx].gsub(/#(?![{$@]).*$/, "")
        opened = line.scan(/#{Regexp.escape(opening_str)}/).size
        closed = line.scan(/#{Regexp.escape(closing_str)}/).size
        return true if opened - closed > 0
      end
      if /(do|\{)\s*\|[^|]*\|\s*(?:#.*)?$/.match @lines[idx]
        return false
      end

      r
    end
  end
end