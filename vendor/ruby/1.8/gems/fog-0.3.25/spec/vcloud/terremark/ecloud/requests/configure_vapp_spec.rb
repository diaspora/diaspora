require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

shared_examples_for "a successful configure vapp" do
  specify { after_vapp_data.should == new_vapp_data }

  describe "#body" do
    its(:body) { should == '' }
  end

  describe "#headers" do
    its(:headers) { should include "Location" }
  end
end

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :configure_vapp }

    let(:original_vapp_data) { vapp_data.dup }
    let(:vapp_data)          { @mock_vm.to_configure_vapp_hash }
    let(:changed_vapp_data)  { {} }
    let(:new_vapp_data)      { vapp_data.update(changed_vapp_data) }
    let(:after_vapp_data)    { @mock_vm.to_configure_vapp_hash }

    describe "#configure_vapp" do
      context "with a valid vapp uri" do
        before { original_vapp_data; subject }

        subject { @vcloud.configure_vapp(@mock_vm.href, new_vapp_data) }

        context "when changing nothing" do
          it_should_behave_like "a successful configure vapp"
        end

        context "when changing CPUs" do
          let(:changed_vapp_data) { { :cpus => @mock_vm.cpus * 2 } }

          it_should_behave_like "a successful configure vapp"
        end

        context "when changing memory" do
          let(:changed_vapp_data) { { :memory => @mock_vm.memory * 2 } }

          it_should_behave_like "a successful configure vapp"
        end

        context "when removing a disk" do
          let(:changed_vapp_data) { { :disks => original_vapp_data[:disks][0...1] } }

          it_should_behave_like "a successful configure vapp"
        end

        context "when adding a disk" do
          let(:changed_vapp_data) { { :disks => original_vapp_data[:disks] + [{ :number => "5", :size => 10 * 1024 * 1024, :resource => (10 * 1024 * 1024).to_s }] } }

          it_should_behave_like "a successful configure vapp"
        end
      end

      context "with an internet_services_uri that doesn't exist" do
        subject { lambda { @vcloud.configure_vapp(URI.parse('https://www.fakey.c/piv8vc99'), new_vapp_data) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

