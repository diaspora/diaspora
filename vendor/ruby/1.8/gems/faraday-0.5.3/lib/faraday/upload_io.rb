begin
  require 'composite_io'
  require 'parts'
  require 'stringio'
rescue LoadError
  puts "Install the multipart-post gem."
  raise
end

# Auto-load multipart-post gem on first request.
module Faraday
  CompositeReadIO = ::CompositeReadIO
  UploadIO        = ::UploadIO
  Parts           = ::Parts
end