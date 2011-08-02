require 'spec_helper'

describe "records" do
  it "delegates to find(:all)" do
    klass = Class.new(ActiveRecord::Base)
    klass.should_receive(:find).with(:all)
    klass.records
  end
end
