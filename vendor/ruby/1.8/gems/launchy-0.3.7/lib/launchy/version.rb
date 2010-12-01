module Launchy
  module Version
    MAJOR   = 0
    MINOR   = 3
    BUILD   = 7

    def self.to_a
      [MAJOR, MINOR, BUILD]
    end

    def self.to_s
      to_a.join(".")
    end
    STRING = Version.to_s.freeze
  end
  VERSION = Version.to_s.freeze
end
