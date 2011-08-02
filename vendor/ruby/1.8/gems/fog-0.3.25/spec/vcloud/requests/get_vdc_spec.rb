require File.join(File.dirname(__FILE__), '..', 'spec_helper')

#
# WARNING: INCOMPLETE
#

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_vcloud_request do
    subject { @vcloud }

    it { should respond_to :get_vdc }

    describe :get_vdc, :type => :vcloud_request do
      context "with a valid vdc uri" do
        before { @vdc = @vcloud.get_vdc(URI.parse(@mock_vdc.href)) }
        subject { @vdc }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.vdc+xml" }

        describe :body do
          subject { @vdc.body }

          it { should have(16).items }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          its(:name)            { should == @mock_vdc.name }
          its(:href)            { should == @mock_vdc.href }
          its(:VmQuota)         { should == "0" }
          its(:Description)     { should == @mock_vdc.name + " VDC" }
          its(:NicQuota)        { should == "0" }
          its(:IsEnabled)       { should == "true" }
          its(:NetworkQuota)    { should == "0" }
          its(:AllocationModel) { should == "AllocationPool" }
          its(:Link)            { should have(7).links }
          its(:ResourceEntities) { should have(1).resource }

          let(:resource_entities) { subject[:ResourceEntities][:ResourceEntity] }
          specify { resource_entities.should have(3).vapps  }
          #FIXME: test for the resources

          its(:ComputeCapacity) { should == {:Memory => { :Units => "MB", :Allocated => @mock_vdc.memory_allocated.to_s, :Limit => @mock_vdc.memory_allocated.to_s },
                                             :Cpu => { :Units => "Mhz", :Allocated => @mock_vdc.cpu_allocated.to_s, :Limit => @mock_vdc.cpu_allocated.to_s } } }

          its(:StorageCapacity) { should == {:Units => "MB", :Allocated => @mock_vdc.storage_allocated.to_s, :Limit => @mock_vdc.storage_allocated.to_s } }

          let(:available_networks) { subject[:AvailableNetworks][:Network] }
          specify { available_networks.should have(2).networks }
          #FIXME :test the available networks

        end
      end
      context "with a vdc uri that doesn't exist" do
        subject { lambda { @vcloud.get_vdc(URI.parse('https://www.fakey.com/api/v0.8/vdc/999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end


