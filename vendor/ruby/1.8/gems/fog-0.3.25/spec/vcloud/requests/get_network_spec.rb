require File.join(File.dirname(__FILE__), '..', 'spec_helper')

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_vcloud_request do
    subject { @vcloud }

    it { should respond_to :get_network }

    describe :get_network, :type => :vcloud_request do
      context "with a valid network uri" do
        before { @network = @vcloud.get_network(URI.parse(@mock_network.href)) }
        subject { @network }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.network+xml" }

        describe :body do
          subject { @network.body }

          it { should have(9).keys }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys
          it { should have_key_with_value :type, "application/vnd.vmware.vcloud.network+xml" }
          it { should have_key_with_value :Features, {:FenceMode => "isolated"} }
          it { should have_key_with_value :Description, @mock_network.name }
          it { should have_key_with_value :href, @mock_network.href }
          it { should have_key_with_value :name, @mock_network.name }
          it { should have_key_with_value :Configuration, {:Gateway => @mock_network.gateway,
                                                           :Netmask => @mock_network.netmask,
                                                           :Dns => @mock_network.dns } }
        end
      end
      context "with a network uri that doesn't exist" do
        subject { lambda { @vcloud.get_network(URI.parse('https://www.fakey.com/api/v0.8/network/999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else

  describe Fog::Vcloud, :type => :vcloud_request do
  end

end
