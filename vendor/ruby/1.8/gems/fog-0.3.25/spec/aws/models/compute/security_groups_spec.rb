require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::SecurityGroups' do

  describe "#all" do

    it "should return a Fog::AWS::Compute::SecurityGroups" do
      AWS[:compute].security_groups.all.should be_a(Fog::AWS::Compute::SecurityGroups)
    end

    it "should include persisted security_groups" do
      security_group = AWS[:compute].security_groups.create(:description => 'groupdescription', :name => 'keyname')
      AWS[:compute].security_groups.get(security_group.name).should_not be_nil
      security_group.destroy
    end

  end

  describe "#create" do

    before(:each) do
      @security_group = AWS[:compute].security_groups.create(:description => 'groupdescription', :name => 'keyname')
    end

    after(:each) do
      @security_group.destroy
    end

    it "should return a Fog::AWS::Compute::SecurityGroup" do
      @security_group.should be_a(Fog::AWS::Compute::SecurityGroup)
    end

    it "should exist on ec2" do
      AWS[:compute].security_groups.get(@security_group.name).should_not be_nil
    end

  end

  describe "#get" do

    it "should return a Fog::AWS::Compute::SecurityGroup if a matching security_group exists" do
      security_group = AWS[:compute].security_groups.create(:description => 'groupdescription', :name => 'keyname')
      get = AWS[:compute].security_groups.get(security_group.name)
      security_group.attributes[:fingerprint].should == get.attributes[:fingerprint]
      security_group.attributes[:name].should == get.attributes[:name]
      security_group.destroy
    end

    it "should return nil if no matching security_group exists" do
      AWS[:compute].security_groups.get('notasecuritygroupname').should be_nil
    end

  end

  describe "#new" do

    it "should return a Fog::AWS::Compute::SecurityGroup" do
      AWS[:compute].security_groups.new(:description => 'groupdescription', :name => 'keyname').should be_a(Fog::AWS::Compute::SecurityGroup)
    end

  end

  describe "#reload" do

    it "should return a Fog::AWS::Compute::SecurityGroups" do
      AWS[:compute].security_groups.all.reload.should be_a(Fog::AWS::Compute::SecurityGroups)
    end

  end

end
