require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :add_internet_service }

    describe "#add_internet_service" do
      before do
        @public_ip = @vcloud.vdcs.first.public_ips.detect {|p| p.name == @mock_public_ip.name }

        @new_service_data = { :name => "Test Service",
                              :protocol => "HTTP",
                              :port => "80",
                              :enabled => "true",
                              :description => "this is a test",
                              :redirect_url => "" }
      end

      context "with a valid Public IP uri" do
        subject { @vcloud.add_internet_service(@public_ip.internet_services.href, @new_service_data ) }

        it "has the right number of Internet Services after" do
          expect { subject }.to change { @vcloud.get_internet_services(@public_ip.internet_services.href).body[:InternetService].size }.by(1)
        end

        it_should_behave_like "all responses"

        let(:body) { subject.body }

        its(:body) { should be_an_instance_of Hash }
        specify { body[:Href].should_not be_empty }
        specify { body[:Name].should == @new_service_data[:name] }
        specify { body[:Protocol].should == @new_service_data[:protocol] }
        specify { body[:Enabled].should == @new_service_data[:enabled] }
        specify { body[:Description].should == @new_service_data[:description] }
        specify { body[:RedirectURL].should == @new_service_data[:redirect_url] }
        specify { body[:Monitor].should == nil }

        let(:referenced_public_ip) { subject.body[:PublicIpAddress] }
        specify { referenced_public_ip.should be_an_instance_of Hash }
        specify { referenced_public_ip[:Name].should == @public_ip.name }
        specify { referenced_public_ip[:Id].should == @public_ip.id }

        it "should update the mock object properly" do
          subject

          public_ip_internet_service = @vcloud.mock_data.public_ip_internet_service_from_href(body[:Href])

          public_ip_internet_service.object_id.to_s.should == body[:Id]
          public_ip_internet_service.node_collection.items.should be_empty
        end
      end

      context "with a public_ips_uri that doesn't exist" do
        subject { lambda { @vcloud.add_internet_service(URI.parse('https://www.fakey.c/piv8vc99'), @new_service_data ) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

