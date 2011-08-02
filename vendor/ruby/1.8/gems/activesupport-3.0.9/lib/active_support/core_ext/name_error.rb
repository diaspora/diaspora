class NameError
  # Extract the name of the missing constant from the exception message.
  def missing_name
    if /undefined local variable or method/ !~ message
      $1 if /((::)?([A-Z]\w*)(::[A-Z]\w*)*)$/ =~ message
    end
  end

  # Was this exception raised because the given name was missing?
  def missing_name?(name)
    if name.is_a? Symbol
      last_name = (missing_name || '').split('::').last
      last_name == name.to_s
    else
      missing_name == name.to_s
    end
  end
end
