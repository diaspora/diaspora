class String
  # Splits text into tokens the way a shell would, handling quoted
  # text as a single token. Use '\"' and "\'" to escape quotes and
  # '\\' to escape a backslash.
  #
  # @return [Array] an array representing the tokens
  def shell_split
    out = [""]
    state = :none
    escape_next = false
    quote = ""
    strip.split(//).each do |char|
      case state
      when :none, :space
        case char
        when /\s/
          out << "" unless state == :space
          state = :space
          escape_next = false
        when "\\"
          if escape_next
            out.last << char
            escape_next = false
          else
            escape_next = true
          end
        when '"', "'"
          if escape_next
            out.last << char
            escape_next = false
          else
            state = char
            quote = ""
          end
        else
          state = :none
          out.last << char
          escape_next = false
        end
      when '"', "'"
        case char
        when '"', "'"
          if escape_next
            quote << char
            escape_next = false
          elsif char == state
            out.last << quote
            state = :none
          else
            quote << char
          end
        when '\\'
          if escape_next
            quote << char
            escape_next = false
          else
            escape_next = true
          end
        else
          quote << char
          escape_next = false
        end
      end
    end
    out
  end
end
