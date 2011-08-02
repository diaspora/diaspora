module Rcov
  # A CodeCoverageAnalyzer is responsible for tracing code execution and
  # returning code coverage and execution count information.
  #
  # Note that you must <tt>require 'rcov'</tt> before the code you want to
  # analyze is parsed (i.e. before it gets loaded or required). You can do that
  # by either invoking ruby with the <tt>-rrcov</tt> command-line option or
  # just:
  #  require 'rcov'
  #  require 'mycode'
  #  # ....
  #
  # == Example
  #
  #  analyzer = Rcov::CodeCoverageAnalyzer.new
  #  analyzer.run_hooked do 
  #    do_foo  
  #    # all the code executed as a result of this method call is traced
  #  end
  #  # ....
  #  
  #  analyzer.run_hooked do 
  #    do_bar
  #    # the code coverage information generated in this run is aggregated
  #    # to the previously recorded one
  #  end
  #
  #  analyzer.analyzed_files   # => ["foo.rb", "bar.rb", ... ]
  #  lines, marked_info, count_info = analyzer.data("foo.rb")
  #
  # In this example, two pieces of code are monitored, and the data generated in
  # both runs are aggregated. +lines+ is an array of strings representing the 
  # source code of <tt>foo.rb</tt>. +marked_info+ is an array holding false,
  # true values indicating whether the corresponding lines of code were reported
  # as executed by Ruby. +count_info+ is an array of integers representing how
  # many times each line of code has been executed (more precisely, how many
  # events where reported by Ruby --- a single line might correspond to several
  # events, e.g. many method calls).
  #
  # You can have several CodeCoverageAnalyzer objects at a time, and it is
  # possible to nest the #run_hooked / #install_hook/#remove_hook blocks: each
  # analyzer will manage its data separately. Note however that no special
  # provision is taken to ignore code executed "inside" the CodeCoverageAnalyzer
  # class. At any rate this will not pose a problem since it's easy to ignore it
  # manually: just don't do
  #   lines, coverage, counts = analyzer.data("/path/to/lib/rcov.rb")
  # if you're not interested in that information.
  class CodeCoverageAnalyzer < DifferentialAnalyzer
    @hook_level = 0
    # defined this way instead of attr_accessor so that it's covered
    def self.hook_level      # :nodoc:
      @hook_level 
    end
     
    def self.hook_level=(x)  # :nodoc: 
      @hook_level = x 
    end 

    def initialize
      @script_lines__ = SCRIPT_LINES__
      super(:install_coverage_hook, :remove_coverage_hook,
            :reset_coverage)
    end
  
    # Return an array with the names of the files whose code was executed inside
    # the block given to #run_hooked or between #install_hook and #remove_hook.
    def analyzed_files
      update_script_lines__
      raw_data_relative.select do |file, lines|
        @script_lines__.has_key?(file)
      end.map{|fname,| fname}
    end

    # Return the available data about the requested file, or nil if none of its
    # code was executed or it cannot be found.
    # The return value is an array with three elements:
    #  lines, marked_info, count_info = analyzer.data("foo.rb")
    # +lines+ is an array of strings representing the 
    # source code of <tt>foo.rb</tt>. +marked_info+ is an array holding false,
    # true values indicating whether the corresponding lines of code were reported
    # as executed by Ruby. +count_info+ is an array of integers representing how
    # many times each line of code has been executed (more precisely, how many
    # events where reported by Ruby --- a single line might correspond to several
    # events, e.g. many method calls).
    #
    # The returned data corresponds to the aggregation of all the statistics
    # collected in each #run_hooked or #install_hook/#remove_hook runs. You can
    # reset the data at any time with #reset to start from scratch.
    def data(filename)
      raw_data = raw_data_relative
      update_script_lines__
      unless @script_lines__.has_key?(filename) && 
             raw_data.has_key?(filename)
        return nil 
      end
      refine_coverage_info(@script_lines__[filename], raw_data[filename])
    end

    # Data for the first file matching the given regexp.
    # See #data.
    def data_matching(filename_re)
      raw_data = raw_data_relative
      update_script_lines__

      match = raw_data.keys.sort.grep(filename_re).first
      return nil unless match

      refine_coverage_info(@script_lines__[match], raw_data[match])
    end

    # Execute the code in the given block, monitoring it in order to gather
    # information about which code was executed.
    def run_hooked; super end

    # Start monitoring execution to gather code coverage and execution count
    # information. Such data will be collected until #remove_hook is called.
    #
    # Use #run_hooked instead if possible.
    def install_hook; super end

    # Stop collecting code coverage and execution count information.
    # #remove_hook will also stop collecting info if it is run inside a
    # #run_hooked block.
    def remove_hook; super end

    # Remove the data collected so far. The coverage and execution count
    # "history" will be erased, and further collection will start from scratch:
    # no code is considered executed, and therefore all execution counts are 0.
    # Right after #reset, #analyzed_files will return an empty array, and
    # #data(filename) will return nil.
    def reset; super end

    def dump_coverage_info(formatters) # :nodoc:
      update_script_lines__
      raw_data_relative.each do |file, lines|
        next if @script_lines__.has_key?(file) == false
        lines = @script_lines__[file]
        raw_coverage_array = raw_data_relative[file]

        line_info, marked_info, 
          count_info = refine_coverage_info(lines, raw_coverage_array)
        formatters.each do |formatter|
          formatter.add_file(file, line_info, marked_info, count_info)
        end
      end
      formatters.each{|formatter| formatter.execute}
    end

    private

    def data_default; {} end

    def raw_data_absolute
      Rcov::RCOV__.generate_coverage_info
    end

    def aggregate_data(aggregated_data, delta)
      delta.each_pair do |file, cov_arr|
        dest = (aggregated_data[file] ||= Array.new(cov_arr.size, 0))
        cov_arr.each_with_index do |x,i| 
          dest[i] ||= 0
          dest[i] += x.to_i
        end
      end
    end

    def compute_raw_data_difference(first, last)
      difference = {}
      last.each_pair do |fname, cov_arr|
        unless first.has_key?(fname)
          difference[fname] = cov_arr.clone
        else
          orig_arr = first[fname]
          diff_arr = Array.new(cov_arr.size, 0)
          changed = false
          cov_arr.each_with_index do |x, i|
            diff_arr[i] = diff = (x || 0) - (orig_arr[i] || 0)
            changed = true if diff != 0
          end
          difference[fname] = diff_arr if changed
        end
      end
      difference
    end

    def refine_coverage_info(lines, covers)
      marked_info = []
      count_info = []
      lines.size.times do |i|
        c = covers[i]
        marked_info << ((c && c > 0) ? true : false)
        count_info << (c || 0)
      end

      script_lines_workaround(lines, marked_info, count_info)
    end

    # Try to detect repeated data, based on observed repetitions in line_info:
    # this is a workaround for SCRIPT_LINES__[filename] including as many copies
    # of the file as the number of times it was parsed.
    def script_lines_workaround(line_info, coverage_info, count_info)
      is_repeated = lambda do |div|
        n = line_info.size / div
        break false unless line_info.size % div == 0 && n > 1
        different = false
        n.times do |i|
        
          things = (0...div).map { |j| line_info[i + j * n] }
          if things.uniq.size != 1
            different = true
            break
          end
        end

        ! different
      end

      factors = braindead_factorize(line_info.size)
      factors.each do |n|
        if is_repeated[n]
          line_info = line_info[0, line_info.size / n]
          coverage_info = coverage_info[0, coverage_info.size / n]
          count_info = count_info[0, count_info.size / n]
        end
      end if factors.size > 1   # don't even try if it's prime

      [line_info, coverage_info, count_info]
    end

    def braindead_factorize(num)
      return [0] if num == 0
      return [-1] + braindead_factorize(-num) if num < 0
      factors = []
      while num % 2 == 0
        factors << 2
        num /= 2
      end
      size = num
      n = 3
      max = Math.sqrt(num)
      while n <= max && n <= size
        while size % n == 0
          size /= n
          factors << n
        end
        n += 2
      end
      factors << size if size != 1
      factors
    end

    def update_script_lines__
      @script_lines__ = @script_lines__.merge(SCRIPT_LINES__)
    end

    public

    def marshal_dump # :nodoc:
      # @script_lines__ is updated just before serialization so as to avoid
      # missing files in SCRIPT_LINES__
      ivs = {}
      update_script_lines__
      instance_variables.each{|iv| ivs[iv] = instance_variable_get(iv)}
      ivs
    end

    def marshal_load(ivs) # :nodoc:
      ivs.each_pair{|iv, val| instance_variable_set(iv, val)}
    end
  end # CodeCoverageAnalyzer
end
