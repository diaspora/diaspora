require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::Address' do

  describe "#initialize" do

    it "should remap attributes from parser" do
      address = AWS[:compute].addresses.new(
        'instanceId'  => 'i-00000000',
        'publicIp'    => '0.0.0.0'
      )
      address.server_id.should == 'i-00000000'
      address.public_ip.should == '0.0.0.0'
    end

  end

  describe "#addresses" do

    it "should return a Fog::AWS::Compute::Addresses" do
      AWS[:compute].addresses.new.collection.should be_a(Fog::AWS::Compute::Addresses)
    end

    it "should be the addresses the address is related to" do
      addresses = AWS[:compute].addresses
      addresses.new.collection.should == addresses
    end

  end

  describe "#destroy" do

    it "should return true if the address is deleted" do
      address = AWS[:compute].addresses.create
      address.destroy.should be_true
    end

  end

  describe "#server=" do
    before(:each) do
      @address = AWS[:compute].addresses.new
      @server = AWS[:compute].servers.create(:image_id => GENTOO_AMI)
    end

    after(:each) do
      @address.destroy
      @server.destroy
    end

    it "should associate with server to an already saved address" do
      @address.save.should be_true
      @server.wait_for { state == 'running' }
      @address.server = @server
      @address.server_id.should == @server.id
    end
  end

  describe "#reload" do

    before(:each) do
      @address = AWS[:compute].addresses.create
      @reloaded = @address.reload
    end

    after(:each) do
      @address.destroy
    end

    it "should return a Fog::AWS::Compute::Address" do
      @reloaded.should be_a(Fog::AWS::Compute::Address)
    end

    it "should reset attributes to remote state" do
      @address.attributes.should == @reloaded.attributes
    end

  end

  describe "#save" do

    before(:each) do
      @address = AWS[:compute].addresses.new
    end

    it "should return true when it succeeds" do
      @address.save.should be_true
      @address.destroy
    end

    it "should not exist in addresses before save" do
      @address.collection.get(@address.public_ip).should be_nil
    end

    it "should exist in buckets after save" do
      @address.save
      @address.collection.get(@address.public_ip).should_not be_nil
      @address.destroy
    end

  end

end
