# The following is imported from ruby 1.9.2 shellwords.rb
#
module Shellwords
  # Escapes a string so that it can be safely used in a Bourne shell
  # command line.
  #
  # Note that a resulted string should be used unquoted and is not
  # intended for use in double quotes nor in single quotes.
  #
  #   open("| grep #{Shellwords.escape(pattern)} file") { |pipe|
  #     # ...
  #   }
  #
  # +String#shellescape+ is a shorthand for this function.
  #
  #   open("| grep #{pattern.shellescape} file") { |pipe|
  #     # ...
  #   }
  #
  def shellescape(str)
    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    str = str.dup

    # Process as a single byte sequence because not all shell
    # implementations are multibyte aware.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")

    return str
  end

  module_function :shellescape

  class << self
    alias escape shellescape
  end

end

class String
  # call-seq:
  #   str.shellescape => string
  #
  # Escapes +str+ so that it can be safely used in a Bourne shell
  # command line.  See +Shellwords::shellescape+ for details.
  #
  def shellescape
    Shellwords.escape(self)
  end
end