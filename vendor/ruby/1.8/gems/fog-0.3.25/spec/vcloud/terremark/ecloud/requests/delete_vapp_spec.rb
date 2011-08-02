require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

shared_examples_for "a failed vapp deletion" do
  it "should not change the mock data" do
    expect { subject }.to change { @mock_vdc.virtual_machines.count }.by(0)
  end

  it "should not change the model data" do
    expect { subject }.to change { vdc.reload.servers.reload.count }.by(0)
  end

  describe "#body" do
    its(:body) { should == '' }
  end

  describe "#headers" do
    its(:headers) { should_not include "Location" }
  end
end

#FIXME: Make this more sane with rspec2
if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :delete_vapp }

    describe "#delete_vapp" do
      context "with a valid vapp uri" do
        subject { @vcloud.delete_vapp(@mock_vm.href) }
        let(:vdc) { @vcloud.vdcs.first }

        context "when there are no internet service nodes attached" do
          it_should_behave_like "all delete responses"

          it "should change the mock data" do
            expect { subject }.to change { @mock_vdc.virtual_machines.count }.by(-1)
          end

          it "should change the model data" do
            expect { subject }.to change { vdc.reload.servers.reload.count }.by(-1)
          end

          describe "#body" do
            its(:body) { should == '' }
          end

          describe "#headers" do
            its(:headers) { should include "Location" }
          end
        end

        context "when there are internet service nodes attached" do
          before do
            vdc.public_ips.first.internet_services.create(:name => "#{@mock_vm.name} service", :port => 1231, :protocol => "TCP", :description => "", :enabled => true).tap do |internet_service|
              internet_service.nodes.create(:name => "#{@mock_vm.name} node", :port => 1231, :description => "", :enabled => true, :ip_address => @mock_vm.ip)
            end
          end

          it_should_behave_like "all delete responses"
          it_should_behave_like "a failed vapp deletion"
        end

        context "when the VM is powered on" do
          before do
            @mock_vm.power_on!
          end

          it_should_behave_like "all delete responses"
          it_should_behave_like "a failed vapp deletion"
        end
      end

      context "with a vapp uri that doesn't exist" do
        subject { lambda { @vcloud.delete_vapp(URI.parse('https://www.fakey.c/piv8vc99')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

