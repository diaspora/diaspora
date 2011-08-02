require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_network }

    describe "#get_network" do
      context "with a valid network uri" do
        before { @network = @vcloud.get_network(@mock_network.href) }
        subject { @network }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.network+xml" }

        describe "#body" do
          subject { @network.body }

          it { should have(9).keys }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          its(:type) { should == "application/vnd.vmware.vcloud.network+xml" }
          its(:Features) { should == @mock_network.features.map {|f| { f[:type] => f[:value] } }.first }
          its(:href) { should == @mock_network.href }
          its(:name) { should == @mock_network.name }
          its(:Configuration) { should == { :Gateway => @mock_network.gateway, :Netmask => @mock_network.netmask } }
          its(:Link) { should ==
                         [{:type => "application/xml",
                            :rel => "down",
                            :href => @mock_network_ip_collection.href,
                            :name => "IP Addresses"},
                           {:type => "application/xml",
                            :rel => "down",
                            :href => @mock_network_extensions.href,
                            :name => @mock_network_extensions.name}]}
        end
      end

      context "with a network uri that doesn't exist" do
        subject { lambda { @vcloud.get_network(URI.parse('https://www.fakey.com/api/v0.8/network/999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

