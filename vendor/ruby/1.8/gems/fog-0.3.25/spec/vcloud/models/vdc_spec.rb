require File.dirname(__FILE__) + '/../spec_helper'

if Fog.mocking?
  describe "Fog::Vcloud::Vdc", :type => :mock_vcloud_model do

    describe :class do
      subject { Fog::Vcloud::Vdc }

      it { should have_identity :href }

      it { should have_only_these_attributes [:href, :name, :type, :description, :other_links, :compute_capacity, :storage_capacity, :available_networks,
                                              :resource_entities, :enabled, :vm_quota, :nic_quota, :network_quota, :allocation_model] }
    end

    context "with no uri" do

      subject { Fog::Vcloud::Vdc.new() }

      it { should have_all_attributes_be_nil }

    end

    context "as a collection member" do
      subject { @vcloud.vdcs[0].reload }

      it { should be_an_instance_of Fog::Vcloud::Vdc }

      its(:href)                  { should == @mock_vdc.href }
      its(:identity)              { should == @mock_vdc.href }
      its(:name)                  { should == @mock_vdc.name }
      its(:other_links)           { should have(7).items }
      its(:resource_entities)     { should have(3).items }
      its(:available_networks)    { should have(2).items }

      its(:compute_capacity)      { should be_an_instance_of Hash }
      its(:compute_capacity)      { should == {:Cpu =>
                                                {:Units => "Mhz", :Allocated => @mock_vdc.cpu_allocated.to_s, :Limit => @mock_vdc.cpu_allocated.to_s},
                                               :Memory =>
                                                {:Units => "MB", :Allocated => @mock_vdc.memory_allocated.to_s, :Limit => @mock_vdc.memory_allocated.to_s}} }
      its(:storage_capacity)      { should be_an_instance_of Hash }
      its(:storage_capacity)      { should == {:Limit => @mock_vdc.storage_allocated.to_s, :Units=>"MB", :Allocated => @mock_vdc.storage_allocated.to_s} }

      its(:vm_quota)              { should == "0" }
      its(:nic_quota)             { should == "0" }
      its(:network_quota)         { should == "0" }

      its(:enabled)               { should == "true" }

    end
  end
else
end
