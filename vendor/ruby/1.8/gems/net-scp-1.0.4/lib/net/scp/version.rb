require 'net/ssh/version'

module Net; class SCP

  # Describes the current version of the Net::SCP library.
  class Version < Net::SSH::Version
    MAJOR = 1
    MINOR = 0
    TINY  = 4

    # The current version, as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The current version, as a String instance
    STRING  = CURRENT.to_s
  end

end; end
