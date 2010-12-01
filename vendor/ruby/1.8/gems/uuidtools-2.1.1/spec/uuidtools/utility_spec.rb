require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe SecureRandom do
  it "should correctly obtain random bits" do
    bits = []
    1000.times do
      bits << SecureRandom.random_bytes(16)
    end
    # Check to make sure that none of the 10,000 strings were duplicates
    (bits.map {|x| x.to_s}).uniq.size.should == bits.size
  end

  it "should return the correct number of random bits" do
    SecureRandom.random_bytes(16).size.should == 16
    SecureRandom.random_bytes(6).size.should == 6
  end

  it "should return a sane random number" do
    SecureRandom.random_number(5000).should < 5000
  end
end
