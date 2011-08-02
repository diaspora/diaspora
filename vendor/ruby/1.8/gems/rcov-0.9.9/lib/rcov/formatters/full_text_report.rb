module Rcov
  class FullTextReport < BaseFormatter # :nodoc:
    DEFAULT_OPTS = {:textmode => :coverage}

    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      @textmode = options[:textmode]
      @color = options[:color]
      super(options)
    end

    def execute
      each_file_pair_sorted do |filename, fileinfo|
        puts "=" * 80
        puts filename
        puts "=" * 80
        lines = SCRIPT_LINES__[filename]

        unless lines
          # try to get the source code from the global code coverage
          # analyzer
          re = /#{Regexp.escape(filename)}\z/
          if $rcov_code_coverage_analyzer and
            (data = $rcov_code_coverage_analyzer.data_matching(re))
            lines = data[0]
          end
        end

        (lines || []).each_with_index do |line, i|
          case @textmode
          when :counts
            puts "%-70s| %6d" % [line.chomp[0,70], fileinfo.counts[i]]
          when :gcc
            puts "%s:%d:%s" % [filename, i+1, line.chomp] unless fileinfo.coverage[i]
          when :coverage
            if @color
              prefix = fileinfo.coverage[i] ? "\e[32;40m" : "\e[31;40m"
              puts "#{prefix}%s\e[37;40m" % line.chomp
            else
              prefix = fileinfo.coverage[i] ? "   " : "!! "
              puts "#{prefix}#{line}"
            end
          end
        end
      end
    end
  end
end