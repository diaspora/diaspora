require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_public_ips }

    describe "#get_public_ips" do
      context "with a valid public_ips_uri" do
        before { @public_ips = @vcloud.get_public_ips(@mock_public_ip_collection.href) }
        subject { @public_ips }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.publicIpsList+xml" }

        describe "#body" do
          subject { @public_ips.body }

          it { should have(1).item }

          describe "[:PublicIPAddress]" do
            subject { @public_ips.body[:PublicIPAddress] }

            it { should have(@mock_public_ip_collection.items.length).addresses }

            [0,1,2].each do |idx|

              context "[#{idx}]" do
                subject { @public_ips.body[:PublicIPAddress][idx] }
                let(:public_ip) { @mock_public_ip_collection.items[idx] }
                its(:Href) { should == public_ip.href }
                its(:Id) { should == public_ip.object_id.to_s }
                its(:Name) { should == public_ip.name }
              end

            end

          end

        end
      end

      context "with a public_ips_uri that doesn't exist" do
        subject { lambda { @vcloud.get_public_ips(URI.parse('https://www.fakey.c/piv8vc99')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
