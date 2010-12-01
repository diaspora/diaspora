class Symbol

  def try_dup
    self
  end

  ##
  # Join with _o_ as a file path
  #
  #   :merb/"core_ext"              #=> "merb/core_ext"
  #   :merb / :core_ext / :string   #=> "merb/core_ext/string"
  #
  # @param [#to_s] o The path component(s) to append.
  #
  # @return [String] The receiver (as path string), concatenated with _o_.
  #
  # @api public
  def /(o)
    File.join(self.to_s, o.to_s)
  end
end
