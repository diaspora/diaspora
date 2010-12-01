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
