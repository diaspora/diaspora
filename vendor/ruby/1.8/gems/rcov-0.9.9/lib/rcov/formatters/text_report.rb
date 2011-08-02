module Rcov
  class TextReport < TextSummary # :nodoc:
    def execute
      print_lines
      print_header
      print_lines

      each_file_pair_sorted do |fname, finfo|
        name = fname.size < 52 ? fname : "..." + fname[-48..-1]
        print_info(name, finfo.num_lines, finfo.num_code_lines,
        finfo.code_coverage)
      end

      print_lines
      print_info("Total", num_lines, num_code_lines, code_coverage)
      print_lines
      puts summary
    end

    def print_info(name, lines, loc, coverage)
      puts "|%-51s | %5d | %5d | %5.1f%% |" % [name, lines, loc, 100 * coverage]
    end

    def print_lines
      puts "+----------------------------------------------------+-------+-------+--------+"
    end

    def print_header
      puts "|                  File                              | Lines |  LOC  |  COV   |"
    end
  end
end