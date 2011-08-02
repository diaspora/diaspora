module Kernel
  def debugger(*args)
    (RSpec.configuration.error_stream || $stderr).puts "\n***** debugger statement ignored, use -d or --debug option to enable debugging\n#{caller(0)[1]}"
  end unless respond_to?(:debugger)
end
