module SimpleOAuth
  module Version
    MAJOR = 0 unless defined? ::SimpleOAuth::Version::MAJOR
    MINOR = 1 unless defined? ::SimpleOAuth::Version::MINOR
    PATCH = 5 unless defined? ::SimpleOAuth::Version::PATCH
    STRING = [MAJOR, MINOR, PATCH].join('.') unless defined? ::SimpleOAuth::Version::STRING
  end
end
