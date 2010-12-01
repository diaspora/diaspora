require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe UUIDTools::UUID, "when generating" do
  it "should correctly generate SHA1 variant UUIDs" do
    UUIDTools::UUID.sha1_create(
      UUIDTools::UUID_URL_NAMESPACE, 'http://sporkmonger.com'
    ).to_s.should == "f2d04685-b787-55da-8644-9bd28a6f5a53"
  end

  it "should correctly generate MD5 variant UUIDs" do
    UUIDTools::UUID.md5_create(
      UUIDTools::UUID_URL_NAMESPACE, 'http://sporkmonger.com'
    ).to_s.should == "15074785-9071-3fe3-89bd-876e4b9e919b"
  end

  it "should correctly generate timestamp variant UUIDs" do
    UUIDTools::UUID.timestamp_create.should_not be_random_node_id
    UUIDTools::UUID.timestamp_create.to_s.should_not ==
      UUIDTools::UUID.timestamp_create.to_s
    current_time = Time.now
    UUIDTools::UUID.timestamp_create(current_time).to_s.should_not ==
      UUIDTools::UUID.timestamp_create(current_time).to_s
    uuids = []
    1000.times do
      uuids << UUIDTools::UUID.timestamp_create
    end
    # Check to make sure that none of the 1,000 UUIDs were duplicates
    (uuids.map {|x| x.to_s}).uniq.size.should == uuids.size
  end

  it "should correctly generate UUIDs without a MAC address" do
    mac_address = UUIDTools::UUID.mac_address
    UUIDTools::UUID.mac_address = nil
    UUIDTools::UUID.timestamp_create.should be_random_node_id
    UUIDTools::UUID.mac_address = mac_address
  end

  it "should correctly generate random number variant UUIDs" do
    uuids = []
    1000.times do
      uuids << UUIDTools::UUID.random_create
    end
    # Check to make sure that none of the 1,000 UUIDs were duplicates
    (uuids.map {|x| x.to_s}).uniq.size.should == uuids.size
  end

  it "should throw an exception if a segment has an invalid value" do
    (lambda do
      UUIDTools::UUID.new(-1, 0, 0, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
    (lambda do
      UUIDTools::UUID.new(4294967296, 0, 0, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if a segment has an invalid value" do
    (lambda do
      UUIDTools::UUID.new(0, -1, 0, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
    (lambda do
      UUIDTools::UUID.new(0, 65536, 0, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if a segment has an invalid value" do
    (lambda do
      UUIDTools::UUID.new(0, 0, -1, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
    (lambda do
      UUIDTools::UUID.new(0, 0, 65536, 0, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if a segment has an invalid value" do
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, -1, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 256, 0, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if a segment has an invalid value" do
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 0, -1, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 0, 256, [0, 0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if nodes are not a collection" do
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 0, 0, :bogus)
    end).should raise_error(TypeError)
  end

  it "should throw an exception if nodes are the wrong size" do
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 0, 0, [0, 0, 0, 0, 0])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if any nodes have invalid values" do
    (lambda do
      UUIDTools::UUID.new(0, 0, 0, 0, 0, [0, 0, 0, 0, 0, 256])
    end).should raise_error(ArgumentError)
  end

  it "should throw an exception if parsing anything but a String" do
    (lambda do
      UUIDTools::UUID.parse(:bogus)
    end).should raise_error(TypeError)
  end

  it "should throw an exception if raw parsing anything but a String" do
    (lambda do
      UUIDTools::UUID.parse_raw(:bogus)
    end).should raise_error(TypeError)
  end
end
