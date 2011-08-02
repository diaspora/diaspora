# Rcov::CoverageInfo is but a wrapper for an array, with some additional
# checks. It is returned by FileStatistics#coverage.
class CoverageInfo
  def initialize(coverage_array)
    @cover = coverage_array.clone
  end

  # Return the coverage status for the requested line. There are four possible
  # return values:
  # * nil if there's no information for the requested line (i.e. it doesn't exist)
  # * true if the line was reported by Ruby as executed
  # * :inferred if rcov inferred it was executed, despite not being reported 
  #   by Ruby.
  # * false otherwise, i.e. if it was not reported by Ruby and rcov's
  #   heuristics indicated that it was not executed
  def [](line)
    @cover[line]
  end

  def []=(line, val) # :nodoc:
    unless [true, false, :inferred].include? val
      raise RuntimeError, "What does #{val} mean?" 
    end
    return if line < 0 || line >= @cover.size
    @cover[line] = val
  end

  # Return an Array holding the code coverage information.
  def to_a
    @cover.clone
  end

  def method_missing(meth, *a, &b) # :nodoc:
    @cover.send(meth, *a, &b)
  end
end
