require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::Volumes' do

  describe "#all" do

    it "should return a Fog::AWS::Compute::Volumes" do
      AWS[:compute].volumes.all.should be_a(Fog::AWS::Compute::Volumes)
    end

    it "should include persisted volumes" do
      volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => 'dev/sdz1')
      AWS[:compute].volumes.get(volume.id).should_not be_nil
      volume.destroy
    end

  end

  describe "#create" do

    before(:each) do
      @volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => 'dev/sdz1')
    end

    after(:each) do
      @volume.destroy
    end

    it "should return a Fog::AWS::Compute::Volume" do
      @volume.should be_a(Fog::AWS::Compute::Volume)
    end

    it "should exist on ec2" do
      AWS[:compute].volumes.get(@volume.id).should_not be_nil
    end

  end

  describe "#get" do

    it "should return a Fog::AWS::Compute::Volume if a matching volume exists" do
      volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => 'dev/sdz1')
      volume.wait_for { ready? }
      get = AWS[:compute].volumes.get(volume.id)
      volume.attributes.should == get.attributes
      volume.destroy
    end

    it "should return nil if no matching address exists" do
      AWS[:compute].volumes.get('vol-00000000').should be_nil
    end

  end

  describe "#new" do

    it "should return a Fog::AWS::Compute::Volume" do
      AWS[:compute].volumes.new.should be_a(Fog::AWS::Compute::Volume)
    end

  end

  describe "#reload" do

    it "should return a Fog::AWS::Compute::Volumes" do
      AWS[:compute].volumes.all.reload.should be_a(Fog::AWS::Compute::Volumes)
    end

  end

end
