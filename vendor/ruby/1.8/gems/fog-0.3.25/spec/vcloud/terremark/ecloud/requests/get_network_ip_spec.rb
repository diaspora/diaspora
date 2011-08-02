require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_network_ip }

    describe "#get_network_ip" do
      context "with a valid ip_uri" do
        before do
          @ip = @vcloud.get_network_ip(@mock_network_ip.href)
        end

        subject { @ip }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.ip+xml" }

        describe "#body" do
          subject { @ip.body }

          its(:Name) { should == @mock_network_ip.name }
          its(:Href) { should == @mock_network_ip.href }
          its(:Id)   { should == @mock_network_ip.object_id.to_s }

        end
      end

      context "with an ip_uri that doesn't exist" do
        subject { lambda { @vcloud.get_network_ip('https://www.fakey.c/piv89') } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
