require File.join(File.dirname(__FILE__),'..','..','..','spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud::Terremark::Ecloud::Vdc", :type => :mock_tmrk_ecloud_model do
    subject { @vcloud }

    it { should respond_to :get_vdc }

    describe :class do
      subject { Fog::Vcloud::Terremark::Ecloud::Vdc }

      it { should have_identity :href }
      it { should have_only_these_attributes [:href, :name, :type, :description, :other_links, :compute_capacity, :storage_capacity, :available_networks,
                                              :resource_entities, :deployed_vm_quota, :instantiated_vm_quota] }
    end

    context "with no uri" do

      subject { Fog::Vcloud::Terremark::Ecloud::Vdc.new() }

      it { should have_all_attributes_be_nil }
    end

    context "as a collection member" do
      subject { @vcloud.vdcs[0].reload }

      its(:href)                  { should == @mock_vdc.href }
      its(:identity)              { should == @mock_vdc.href }
      its(:name)                  { should == @mock_vdc.name }
      its(:public_ips)            { should be_an_instance_of Fog::Vcloud::Terremark::Ecloud::PublicIps }
      its(:other_links)           { should have(4).items }
      its(:resource_entities)     { should have(3).items }
      its(:available_networks)    { should have(2).items }

      its(:compute_capacity)      { should == {:Memory =>
                                                {:Allocated => @mock_vdc.memory_allocated.to_s, :Units => "bytes * 2^20"}, 
                                               :DeployedVmsQuota =>
                                                {:Limit => "-1", :Used => "-1"},
                                               :InstantiatedVmsQuota =>
                                                {:Limit => "-1", :Used => "-1"}, 
                                               :Cpu =>
                                                {:Allocated => @mock_vdc.cpu_allocated.to_s, :Units => "hz * 10^6"}} }

      its(:storage_capacity)      { should == {:Allocated => @mock_vdc.storage_allocated.to_s, :Used => @mock_vdc.storage_used.to_s, :Units => "bytes * 10^9"} }

      its(:deployed_vm_quota)     { should == nil }
      its(:instantiated_vm_quota) { should == nil }

      its(:public_ips)            { should have(3).public_ips }
      its(:internet_services)     { should have(4).services }
      its(:networks)              { should have(2).networks }
      its(:servers)               { should have(3).servers }

      #FIXME: need to mock tasks related requests first
      #its(:tasks)                 { should have(0).tasks }

      #FIXME: need to mock catalog related requests first
      #its(:catalog)               { should have(0).entries }

    end
  end
else
end
