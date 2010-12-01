require 'stringio'
require 'rack/logger'

describe Rack::Logger do
  should "log to rack.errors" do
    app = lambda { |env|
      log = env['rack.logger']
      log.debug("Created logger")
      log.info("Program started")
      log.warn("Nothing to do!")

      [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
    }

    errors = StringIO.new
    Rack::Logger.new(app).call('rack.errors' => errors)
    errors.string.should.match(/INFO -- : Program started/)
    errors.string.should.match(/WARN -- : Nothing to do/)
  end
end
