# TODO (2011-05-08) - remove this as soon as spork 0.9.0 is released
if defined?(Spork::TestFramework::RSpec)
  class Spork::TestFramework::RSpec < Spork::TestFramework
    def run_tests(argv, err, out)
      ::RSpec::Core::CommandLine.new(argv).run(err, out)
    end
  end
end
