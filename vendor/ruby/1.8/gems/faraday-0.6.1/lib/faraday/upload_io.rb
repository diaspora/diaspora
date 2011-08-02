begin
  require 'composite_io'
  require 'parts'
  require 'stringio'
rescue LoadError
  $stderr.puts "Install the multipart-post gem."
  raise
end

module Faraday
  class CompositeReadIO < ::CompositeReadIO
    attr_reader :length
    
    def initialize(parts)
      @length = parts.inject(0) { |sum, part| sum + part.length }
      ios = parts.map{ |part| part.to_io }
      super(*ios)
    end
  end

  UploadIO = ::UploadIO
  Parts = ::Parts
end
