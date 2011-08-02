# Why: http://groups.google.com/group/cukes/browse_thread/thread/5682d41436e235d7
begin
  require 'minitest/unit'
  class MiniTest::Unit
    class << self
      @@installed_at_exit = true
    end

    def run(*)
      0
    end
  end
rescue LoadError => ignore
end

# Do the same for Test::Unit
begin
  require 'test/unit'
  module Test::Unit
    def self.run?
      true
    end
  end
rescue LoadError => ignore
end
