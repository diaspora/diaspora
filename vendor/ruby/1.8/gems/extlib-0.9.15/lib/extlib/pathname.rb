class Pathname
  # Append path segments and expand to absolute path
  #
  #   file = Pathname(Dir.pwd) / "subdir1" / :subdir2 / "filename.ext"
  #
  # @param [Pathname, String, #to_s] path path segment to concatenate with receiver
  #
  # @return [Pathname]
  #   receiver with _path_ appended and expanded to an absolute path
  #
  # @api public
  def /(path)
    (self + path).expand_path
  end

  # alias to_s to to_str when to_str not defined
  unless public_instance_methods(false).any? { |m| m.to_sym == :to_str }
    alias to_str to_s
  end
end # class Pathname
