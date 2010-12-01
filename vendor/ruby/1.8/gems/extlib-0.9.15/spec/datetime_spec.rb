require 'spec_helper'
require 'extlib/datetime'

describe DateTime, "#to_time" do
  before do
    @expected = Time.now.to_s
    @datetime = DateTime.parse(@expected)
  end

  it "should return a copy of time" do
    time = @datetime.to_time
    time.class.should == Time
    time.to_s.should == @expected
  end
end

describe Time, "#to_datetime" do
  it "should return a copy of its self" do
    datetime = DateTime.now
    datetime.to_datetime.should == datetime
  end
end
