require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe UUIDTools::UUID, "when obtaining a MAC address" do
  before do
    @mac_address = UUIDTools::UUID.mac_address
  end

  it "should obtain a MAC address" do
    @mac_address.should_not be_nil
  end

  it "should cache the MAC address" do
    @mac_address.object_id.should == UUIDTools::UUID.mac_address.object_id
  end
end
