module Rcov
  class TextCoverageDiff < BaseFormatter # :nodoc:
    FORMAT_VERSION = [0, 1, 0]
    DEFAULT_OPTS = { :textmode => :coverage_diff, :coverage_diff_mode => :record,
                     :coverage_diff_file => "coverage.info", :diff_cmd => "diff", 
                     :comments_run_by_default => true }
    HUNK_HEADER = /@@ -\d+,\d+ \+(\d+),(\d+) @@/
  
    def SERIALIZER
      # mfp> this was going to be YAML but I caught it failing at basic
      # round-tripping, turning "\n" into "" and corrupting the data, so
      # it must be Marshal for now
      Marshal
    end

    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      @textmode = options[:textmode]
      @color = options[:color]
      @mode = options[:coverage_diff_mode]
      @state_file = options[:coverage_diff_file]
      @diff_cmd = options[:diff_cmd]
      @gcc_output = options[:gcc_output]
      super(options)
    end

    def execute
      case @mode
      when :record
        record_state
      when :compare
        compare_state
      else
        raise "Unknown TextCoverageDiff mode: #{mode.inspect}."
      end
    end

    def record_state
      state = {}
      each_file_pair_sorted do |filename, fileinfo|
        state[filename] = {:lines    => SCRIPT_LINES__[filename], :coverage => fileinfo.coverage.to_a,:counts   => fileinfo.counts}
      end
      File.open(@state_file, "w") do |f|
        self.SERIALIZER.dump([FORMAT_VERSION, state], f)
      end
    rescue
      $stderr.puts <<-EOF
      Couldn't save coverage data to #{@state_file}.
      EOF
    end # '

    require 'tempfile'
    def compare_state
      return unless verify_diff_available
      begin
        format, prev_state = File.open(@state_file){|f| self.SERIALIZER.load(f) }
      rescue
        $stderr.puts <<-EOF
        Couldn't load coverage data from #{@state_file}.
        EOF
        return # '
      end
      if !(Array === format) or
        FORMAT_VERSION[0] != format[0] || FORMAT_VERSION[1] < format[1]
        $stderr.puts <<-EOF
        Couldn't load coverage data from #{@state_file}.
        The file is saved in the format  #{format.inspect[0..20]}.
        This rcov executable understands #{FORMAT_VERSION.inspect}.
        EOF
        return # '
      end
      each_file_pair_sorted do |filename, fileinfo|
        old_data = Tempfile.new("#{mangle_filename(filename)}-old")
        new_data = Tempfile.new("#{mangle_filename(filename)}-new")
        if prev_state.has_key? filename
          old_code, old_cov = prev_state[filename].values_at(:lines, :coverage)
          old_code.each_with_index do |line, i|
            prefix = old_cov[i] ? "   " : "!! "
            old_data.write "#{prefix}#{line}"
          end
        else
          old_data.write ""
        end
        old_data.close
        SCRIPT_LINES__[filename].each_with_index do |line, i|
          prefix = fileinfo.coverage[i] ? "   " : "!! "
          new_data.write "#{prefix}#{line}"
        end
        new_data.close

        diff = `#{@diff_cmd} -u "#{old_data.path}" "#{new_data.path}"`
        new_uncovered_hunks = process_unified_diff(filename, diff)
        old_data.close!
        new_data.close!
        display_hunks(filename, new_uncovered_hunks)
      end
    end

    def display_hunks(filename, hunks)
      return if hunks.empty?
      puts
      puts "=" * 80
      puts "!!!!! Uncovered code introduced in #{filename}"

      hunks.each do |offset, lines|
        if @gcc_output
          lines.each_with_index do |line,i|
            lineno = offset + i
            flag = (/^!! / !~ line) ? "-" : ":"
            prefix = "#{filename}#{flag}#{lineno}#{flag}"
            puts "#{prefix}#{line[3..-1]}"
          end
        elsif @color
          puts "### #{filename}:#{offset}"
          lines.each do |line|
            prefix = (/^!! / !~ line) ? "\e[32;40m" : "\e[31;40m"
            puts "#{prefix}#{line[3..-1].chomp}\e[37;40m"
          end
        else
          puts "### #{filename}:#{offset}"
          puts lines
        end
      end
    end

    def verify_diff_available
      old_stderr = STDERR.dup
      old_stdout = STDOUT.dup
      new_stderr = Tempfile.new("rcov_check_diff")
      STDERR.reopen new_stderr.path
      STDOUT.reopen new_stderr.path

      retval = system "#{@diff_cmd} --version"
      unless retval
        old_stderr.puts <<EOF
  The '#{@diff_cmd}' executable seems not to be available.
  You can specify which diff executable should be used with --diff-cmd.
  If your system doesn't have one, you might want to use Diff::LCS's:
  gem install diff-lcs
  and use --diff-cmd=ldiff.
EOF
        return false
      end
      true
    ensure
      STDOUT.reopen old_stdout
      STDERR.reopen old_stderr
      new_stderr.close!
    end

    def process_unified_diff(filename, diff)
      current_hunk = []
      current_hunk_start = 0
      keep_current_hunk = false
      state = :init
      interesting_hunks = []
      diff.each_with_index do |line, i|
        #puts "#{state} %5d #{line}" % i
        case state
        when :init
          if md = HUNK_HEADER.match(line)
            current_hunk = []
            current_hunk_start = md[1].to_i
            state = :body
          end
        when :body
          case line
          when HUNK_HEADER
            new_start = $1.to_i
            if keep_current_hunk
              interesting_hunks << [current_hunk_start, current_hunk]
            end
            current_hunk_start = new_start
            current_hunk = []
            keep_current_hunk = false
          when /^-/
            # ignore
          when /^\+!! /
            keep_current_hunk = true
            current_hunk << line[1..-1]
          else
            current_hunk << line[1..-1]
          end
        end
      end
      if keep_current_hunk
        interesting_hunks << [current_hunk_start, current_hunk]
      end

      interesting_hunks
    end
  end
end