require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_public_ip }

    describe "#get_public_ip" do
      context "with a valid public_ip_uri" do
        before do
          @public_ip = @vcloud.get_public_ip(@mock_public_ip.href)
        end

        subject { @public_ip }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.publicIp+xml" }

        describe "#body" do
          subject { @public_ip.body }

          its(:Name) { should == @mock_public_ip.name }
          its(:Href) { should == @mock_public_ip.href }
          its(:Id)   { should == @mock_public_ip.object_id.to_s }

        end
      end

      context "with a public_ips_uri that doesn't exist" do
        subject { lambda { @vcloud.get_public_ip(URI.parse('https://www.fakey.c/piv89')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
