# This is fishy. Try to get rid of it....
begin
  require 'test/unit/testresult'
  # So that Test::Unit doesn't launch at the end - makes it think it has already been run.
  Test::Unit.run = true if Test::Unit.respond_to?(:run=)
rescue LoadError => ignore
end
