require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::Volume' do

  describe "#initialize" do

    it "should remap attributes from parser" do
      volume = AWS[:compute].volumes.new(
        'attachTime'        => 'now',
        'availabilityZone'  => 'us-east-1a',
        'createTime'        => 'recently',
        'instanceId'        => 'i-00000000',
        'snapshotId'        => 'snap-00000000',
        'volumeId'          => 'vol-00000000'
      )
      volume.attached_at.should == 'now'
      volume.availability_zone.should == 'us-east-1a'
      volume.created_at.should == 'recently'
      volume.server_id.should == 'i-00000000'
      volume.snapshot_id.should == 'snap-00000000'
      volume.id.should == 'vol-00000000'
    end

  end

  describe "#collection" do

    it "should return a Fog::AWS::Compute::Volumes" do
      AWS[:compute].volumes.new.collection.should be_a(Fog::AWS::Compute::Volumes)
    end

    it "should be the volumes the volume is related to" do
      volumes = AWS[:compute].volumes
      volumes.new.collection.should == volumes
    end

  end

  describe "#destroy" do

    it "should return true if the volume is deleted" do
      volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => '/dev/sdz1')
      volume.destroy.should be_true
    end

    it 'should fail if the volume is attached to an instance' do
      server = AWS[:compute].servers.create(:image_id => GENTOO_AMI)
      server.wait_for { ready? }
      volume = AWS[:compute].volumes.create(:availability_zone => server.availability_zone, :size => 1, :device => '/dev/sdz1')
      volume.server = server
      lambda { volume.destroy }.should raise_error
    end

  end

  describe "#server=" do
    before(:all) do
      @server = AWS[:compute].servers.create(:image_id => GENTOO_AMI)
      @server.wait_for { ready? }
    end

    after(:all) do
      @server.destroy
    end

    before(:each) do
      @volume = AWS[:compute].volumes.new(:availability_zone => @server.availability_zone, :size => 1, :device => '/dev/sdz1')
    end

    after(:each) do
      if @volume.id
        @volume.wait_for { state == 'in-use' }
        @volume.server = nil
        @volume.wait_for { ready? }
        @volume.destroy
      end
    end

    it "should not attach to server if the volume has not been saved" do
      @volume.server = @server
      @volume.server_id.should_not == @server.id
    end

    it "should change the availability_zone if the volume has not been saved" do
      @volume.server = @server
      @volume.availability_zone.should == @server.availability_zone
    end

    it "should attach to server when the volume is saved" do
      @volume.server = @server
      @volume.save.should be_true
      @volume.server_id.should == @server.id
    end

    it "should attach to server to an already saved volume" do
      @volume.save.should be_true
      @volume.server = @server
      @volume.server_id.should == @server.id
    end

    it "should not change the availability_zone if the volume has been saved" do
      @volume.save.should be_true
      @volume.server = @server
      @volume.availability_zone.should == @server.availability_zone
    end
  end

  describe "#reload" do

    before(:each) do
      @volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => '/dev/sdz1')
      @reloaded = @volume.reload
    end

    after(:each) do
      @volume.destroy
    end

    it "should return a Fog::AWS::Compute::Volume" do
      @reloaded.should be_a(Fog::AWS::Compute::Volume)
    end

    it "should reset attributes to remote state" do
      @volume.attributes.should == @reloaded.attributes
    end

  end

  describe "#save" do

    before(:each) do
      @volume = AWS[:compute].volumes.new(:availability_zone => 'us-east-1a', :size => 1, :device => '/dev/sdz1')
    end

    it "should return true when it succeeds" do
      @volume.save.should be_true
      @volume.destroy
    end

    it "should not exist in volumes before save" do
      AWS[:compute].volumes.get(@volume.id).should be_nil
    end

    it "should exist in buckets after save" do
      @volume.save
      AWS[:compute].volumes.get(@volume.id).should_not be_nil
      @volume.destroy
    end

  end

end
