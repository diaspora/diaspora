require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

#FIXME: Make this more sane with rspec2
if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :delete_internet_service }

    describe "#delete_internet_service" do
      context "with a valid internet service uri" do
        subject { @vcloud.delete_internet_service(@mock_service.href) }

        it_should_behave_like "all delete responses"

        let(:public_ip) { @vcloud.vdcs.first.public_ips.detect {|i| i.name == @mock_public_ip.name } }

        it "should change the mock data" do
          expect { subject }.to change { @mock_public_ip.internet_service_collection.items.count }.by(-1)
        end

        it "should change the count by -1" do
          expect { subject }.to change { public_ip.reload.internet_services.reload.length }.by(-1)
        end

        describe "#body" do
          its(:body) { should == '' }
        end
      end
    end
  end
else
end

