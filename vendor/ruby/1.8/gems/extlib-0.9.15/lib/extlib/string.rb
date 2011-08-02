require "pathname"

class String
  ##
  # Escape all regexp special characters.
  #
  #   "*?{}.".escape_regexp   #=> "\\*\\?\\{\\}\\."
  #
  # @return [String] Receiver with all regexp special characters escaped.
  #
  # @api public
  def escape_regexp
    Regexp.escape self
  end

  ##
  # Unescape all regexp special characters.
  #
  #   "\\*\\?\\{\\}\\.".unescape_regexp #=> "*?{}."
  #
  # @return [String] Receiver with all regexp special characters unescaped.
  #
  # @api public
  def unescape_regexp
    self.gsub(/\\([\.\?\|\(\)\[\]\{\}\^\$\*\+\-])/, '\1')
  end

  ##
  # Convert to snake case.
  #
  #   "FooBar".snake_case           #=> "foo_bar"
  #   "HeadlineCNNNews".snake_case  #=> "headline_cnn_news"
  #   "CNN".snake_case              #=> "cnn"
  #
  # @return [String] Receiver converted to snake case.
  #
  # @api public
  def snake_case
    return downcase if match(/\A[A-Z]+\z/)
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
    gsub(/([a-z])([A-Z])/, '\1_\2').
    downcase
  end

  ##
  # Convert to camel case.
  #
  #   "foo_bar".camel_case          #=> "FooBar"
  #
  # @return [String] Receiver converted to camel case.
  #
  # @api public
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  ##
  # Convert a path string to a constant name.
  #
  #   "merb/core_ext/string".to_const_string #=> "Merb::CoreExt::String"
  #
  # @return [String] Receiver converted to a constant name.
  #
  # @api public
  def to_const_string
    gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  ##
  # Convert a constant name to a path, assuming a conventional structure.
  #
  #   "FooBar::Baz".to_const_path # => "foo_bar/baz"
  #
  # @return [String] Path to the file containing the constant named by receiver
  #   (constantized string), assuming a conventional structure.
  #
  # @api public
  def to_const_path
    snake_case.gsub(/::/, "/")
  end

  ##
  # Join with _o_ as a file path.
  #
  #   "merb"/"core_ext" #=> "merb/core_ext"
  #
  # @param [String] o Path component to join with receiver.
  #
  # @return [String] Receiver joined with o as a file path.
  #
  # @api public
  def /(o)
    File.join(self, o.to_s)
  end

  ##
  # Calculate a relative path *from* _other_.
  #
  #   "/opt/local/lib".relative_path_from("/opt/local/lib/ruby/site_ruby") # => "../.."
  #
  # @param [String] other Base path to calculate *from*.
  #
  # @return [String] Relative path from _other_ to receiver.
  #
  # @api public
  def relative_path_from(other)
    Pathname.new(self).relative_path_from(Pathname.new(other)).to_s
  end

  # Overwrite this method to provide your own translations.
  def self.translate(value)
    translations[value] || value
  end

  def self.translations
    @translations ||= {}
  end

  ##
  # Replace sequences of whitespace (including newlines) with either
  # a single space or remove them entirely (according to param _spaced_)
  #
  #   <<QUERY.compress_lines
  #     SELECT name
  #     FROM users
  #   QUERY => "SELECT name FROM users"
  #
  # @param [TrueClass, FalseClass] spaced (default=true)
  #   Determines whether returned string has whitespace collapsed or removed
  #
  # @return [String] Receiver with whitespace (including newlines) replaced
  #
  # @api public
  def compress_lines(spaced = true)
    split($/).map { |line| line.strip }.join(spaced ? ' ' : '')
  end

  ##
  # Remove whitespace margin.
  #
  # @param [Object] indicator ???
  #
  # @return [String] receiver with whitespace margin removed
  #
  # @api public
  def margin(indicator = nil)
    lines = self.dup.split($/)

    min_margin = 0
    lines.each do |line|
      if line =~ /^(\s+)/ && (min_margin == 0 || $1.size < min_margin)
        min_margin = $1.size
      end
    end
    lines.map { |line| line.sub(/^\s{#{min_margin}}/, '') }.join($/)
  end

  ##
  # Formats String for easy translation. Replaces an arbitrary number of
  # values using numeric identifier replacement.
  #
  #   "%s %s %s" % %w(one two three)        #=> "one two three"
  #   "%3$s %2$s %1$s" % %w(one two three)  #=> "three two one"
  #
  # @param [#to_s] values
  #   A list of values to translate and interpolate into receiver
  #
  # @return [String]
  #   Receiver translated with values translated and interpolated positionally
  #
  # @api public
  def t(*values)
    self.class::translate(self) % values.collect! { |value| value.frozen? ? value : self.class::translate(value.to_s) }
  end
end # class String
