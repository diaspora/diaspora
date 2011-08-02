module Rcov
  class TextSummary < BaseFormatter # :nodoc:
    def execute
      puts summary
    end

    def summary
      "%.1f%%   %d file(s)   %d Lines   %d LOC" % [code_coverage * 100, @files.size, num_lines, num_code_lines]
    end
  end
end
