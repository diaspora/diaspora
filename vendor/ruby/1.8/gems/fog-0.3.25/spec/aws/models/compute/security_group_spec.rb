require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::SecurityGroup' do

  describe "#initialize" do

    it "should remap attributes from parser" do
      security_group = AWS[:compute].security_groups.new(
        'groupDescription' => 'description',
        'groupName'        => 'name',
        'ipPermissions'    => 'permissions',
        'ownerId'          => 'owner'
      )
      security_group.description.should == 'description'
      security_group.name.should == 'name'
      security_group.ip_permissions.should == 'permissions'
      security_group.owner_id.should == 'owner'
    end

  end

  describe "#collection" do

    it "should return a Fog::AWS::Compute::SecurityGroups" do
      AWS[:compute].security_groups.new.collection.should be_a(Fog::AWS::Compute::SecurityGroups)
    end

    it "should be the security_groups the keypair is related to" do
      security_groups = AWS[:compute].security_groups
      security_groups.new.collection.should == security_groups
    end

  end

  describe "#destroy" do

    it "should return true if the security_group is deleted" do
      address = AWS[:compute].security_groups.create(:description => 'groupdescription', :name => 'keyname')
      address.destroy.should be_true
    end

  end

  describe "#reload" do

    before(:each) do
      @security_group = AWS[:compute].security_groups.create(:description => 'groupdescription', :name => 'keyname')
      @reloaded = @security_group.reload
    end

    after(:each) do
      @security_group.destroy
    end

    it "should return a Fog::AWS::Compute::SecurityGroup" do
      @reloaded.should be_a(Fog::AWS::Compute::SecurityGroup)
    end

    it "should reset attributes to remote state" do
      @security_group.attributes.should == @reloaded.attributes
    end

  end

  describe "#save" do

    before(:each) do
      @security_group = AWS[:compute].security_groups.new(:description => 'groupdescription', :name => 'keyname')
    end

    it "should return true when it succeeds" do
      @security_group.save.should be_true
      @security_group.destroy
    end

    it "should not exist in security_groups before save" do
      AWS[:compute].security_groups.get(@security_group.name).should be_nil
    end

    it "should exist in buckets after save" do
      @security_group.save
      AWS[:compute].security_groups.get(@security_group.name).should_not be_nil
      @security_group.destroy
    end

  end

end
