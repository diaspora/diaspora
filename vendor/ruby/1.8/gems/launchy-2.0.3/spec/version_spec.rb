require 'spec_helper'

describe 'Launchy::VERSION' do
  it "should have a #.#.# format" do
    Launchy::VERSION.must_match( /\d+\.\d+\.\d+/ )
    Launchy::Version.to_s.must_match( /\d+\.\d+\.\d+/ )
    Launchy::Version.to_a.each do |n|
      n.to_i.must_be :>=, 0
    end
  end
end
