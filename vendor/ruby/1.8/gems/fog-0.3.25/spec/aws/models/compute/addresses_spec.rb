require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::Addresses' do

  describe "#all" do

    it "should return a Fog::AWS::Compute::Addresses" do
      AWS[:compute].addresses.all.should be_a(Fog::AWS::Compute::Addresses)
    end

    it "should include persisted addresses" do
      address = AWS[:compute].addresses.create
      AWS[:compute].addresses.get(address.public_ip).should_not be_nil
      address.destroy
    end

  end

  describe "#create" do

    before(:each) do
      @address = AWS[:compute].addresses.create
    end

    after(:each) do
      @address.destroy
    end

    it "should return a Fog::AWS::Compute::Address" do
      @address.should be_a(Fog::AWS::Compute::Address)
    end

    it "should exist on ec2" do
      AWS[:compute].addresses.get(@address.public_ip).should_not be_nil
    end

  end

  describe "#get" do

    it "should return a Fog::AWS::Compute::Address if a matching address exists" do
      address = AWS[:compute].addresses.create
      get = AWS[:compute].addresses.get(address.public_ip)
      address.attributes.should == get.attributes
      address.destroy
    end

    it "should return nil if no matching address exists" do
      AWS[:compute].addresses.get('0.0.0.0').should be_nil
    end

  end

  describe "#new" do

    it "should return a Fog::AWS::Compute::Address" do
      AWS[:compute].addresses.new.should be_a(Fog::AWS::Compute::Address)
    end

  end

  describe "#reload" do

    it "should return a Fog::AWS::Compute::Addresses" do
      AWS[:compute].addresses.all.reload.should be_a(Fog::AWS::Compute::Addresses)
    end

  end

end
