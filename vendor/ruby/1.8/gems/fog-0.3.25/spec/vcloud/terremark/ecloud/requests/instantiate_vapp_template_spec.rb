require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :instantiate_vapp_template }

    describe "#instantiate_vapp_template" do
      let(:vdc) { @vcloud.vdcs.first }
      let(:mock_vdc) { @mock_vdc }

      let(:catalog_item) { vdc.catalog.first }
      let(:mock_catalog_item) { @vcloud.mock_data.catalog_item_from_href(catalog_item.href) }

      let(:new_vapp_data) do
        {
          :name => "foobar",
          :network_uri => @mock_network.href,
          :row => "test row",
          :group => "test group",
          :memory => 1024,
          :cpus => 2,
          :vdc_uri => @mock_vdc.href
        }
      end

      let(:added_mock_data) { mock_vdc.virtual_machines.last }

      context "with a valid data" do
        let(:template_instantiation) { @vcloud.instantiate_vapp_template(catalog_item.href, new_vapp_data) }
        subject { template_instantiation }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/xml" }

        it "updates the mock data properly" do
          expect { subject }.to change { mock_vdc.virtual_machines.size }.by(1)
        end

        describe "added mock data" do
          before  { template_instantiation }
          subject { added_mock_data }

          it { should be_an_instance_of Fog::Vcloud::MockDataClasses::MockVirtualMachine }

          its(:name) { should == new_vapp_data[:name] }
          its(:memory) { should == new_vapp_data[:memory] }
          its(:cpus) { should == new_vapp_data[:cpus] }
          # WHAT
          specify { subject._parent.should == mock_vdc }
          specify { subject.status.should == 2 }
          specify { subject.disks.should == mock_catalog_item.disks }
          # its(:_parent) { should == mock_vdc }
          #its(:status) { should == 2 }
          #its(:disks) { should == mock_catalog_item.disks }
        end

        describe "server based on added mock data" do
          before  { template_instantiation }
          subject { vdc.servers.reload.detect {|s| s.href == added_mock_data.href }.reload }

          its(:name) { should == new_vapp_data[:name] }
        end

        describe "#body" do
          subject { template_instantiation.body }

          it { should have(9).items }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          its(:href) { should == added_mock_data.href }
          its(:type) { should == "application/vnd.vmware.vcloud.vApp+xml" }
          its(:name) { should == new_vapp_data[:name] }
          its(:status) { should == "0" }
          its(:size) { should == "4" }

          it { should include :Link }

          describe "Link" do
            subject { template_instantiation.body[:Link] }

            it { should have(3).keys }

            its(:rel)  { should == "up" }
            its(:type) { should == "application/vnd.vmware.vcloud.vdc+xml" }
            # WHAT
            its(:href) { blah = vdc.href; should == blah }
          end
        end
      end
    end
  end
else
end
