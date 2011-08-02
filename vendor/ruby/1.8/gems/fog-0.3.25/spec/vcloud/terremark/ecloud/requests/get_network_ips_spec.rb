require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_network_ips }

    describe "#get_network_ips" do
      context "with a valid VDC network ips_uri" do
        before { @ips = @vcloud.get_network_ips(@mock_network_ip_collection.href) }
        subject { @ips }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.ipAddressesList+xml" }

        describe "#body" do
          subject { @ips.body }

          it { should have(1).item }

          context "[:IpAddress]" do
            subject { @ips.body[:IpAddress] }

            # Note the real TMRK API returns only "assigned" ips currently
            # This is a bug they've slated to fix in the next release.
            it { should have(252).addresses }

          end

          context "one we know is assigned" do
            let(:address) { @ips.body[:IpAddress][0] }
            specify { address.should have(5).keys }
            specify { address[:Status].should == "Assigned" }
            specify { address[:Server].should == "Broom 1" }
            specify { address[:Name].should == "1.2.3.3" }
            specify { address[:RnatAddress].should == "99.1.2.3" }
          end

          context "one we know is assigned" do
            let(:address) { @ips.body[:IpAddress][100] }
            specify { address.should have(4).keys }
            specify { address[:Status].should == "Available" }
            specify { address.has_key?(:Server).should be_false }
            specify { address[:Name].should == "1.2.3.103" }
            specify { address[:RnatAddress].should == "99.1.2.3" }
          end
        end
      end

      context "with a network ips uri that doesn't exist" do
        subject { lambda { @vcloud.get_network_ips(URI.parse('https://www.fakey.c/piv8vc99')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
