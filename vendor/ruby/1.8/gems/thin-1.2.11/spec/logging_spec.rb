require File.dirname(__FILE__) + '/spec_helper'

class TestLogging
  include Logging
end

describe Logging do
  before do
    Logging.silent = false
    @object = TestLogging.new
  end
  
  it "should output debug when set to true" do
    Logging.debug = true
    @object.should_receive(:puts)
    @object.debug 'hi'
  end

  it "should output trace when set to true" do
    Logging.trace = true
    @object.should_receive(:puts)
    @object.trace 'hi'
  end

  it "should not output when silenced" do
    Logging.silent = true
    @object.should_not_receive(:puts)
    @object.log 'hi'
  end
  
  it "should not output when silenced as instance method" do
    @object.silent = true
    
    @object.should_not_receive(:puts)
    @object.log 'hi'
  end
  
  it "should be usable as module functions" do
    Logging.silent = true
    Logging.log "hi"
  end
  
  after do
    Logging.silent = true
  end
end