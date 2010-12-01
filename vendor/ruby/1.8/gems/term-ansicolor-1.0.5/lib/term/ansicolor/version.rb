module Term
  module ANSIColor
    # Term::ANSIColor version
    VERSION         = '1.0.5'
    VERSION_ARRAY   = VERSION.split(/\./).map { |x| x.to_i } # :nodoc:
    VERSION_MAJOR   = VERSION_ARRAY[0] # :nodoc:
    VERSION_MINOR   = VERSION_ARRAY[1] # :nodoc:
    VERSION_BUILD   = VERSION_ARRAY[2] # :nodoc:
  end
end
