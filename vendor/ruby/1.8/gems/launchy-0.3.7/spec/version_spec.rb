require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'yaml'

describe "Launchy::VERSION" do
  it "should have a #.#.# format" do
    Launchy::VERSION.should =~ /\d+\.\d+\.\d+/
    Launchy::Version.to_a.each do |n|
      n.to_i.should >= 0
    end
  end
end
