require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_catalog_item }

    describe "#get_catalog_item" do
      context "with a valid catalog_item_uri" do
        before { @catalog_item = @vcloud.get_catalog_item(@vcloud.vdcs.first.catalog.first.href) }
        subject { @catalog_item }
        let(:mock_data_catalog_item) { @mock_data.catalog_item_from_href(@catalog_item.body[:href]) }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.catalogItem+xml" }

        describe "#body" do
          subject { @catalog_item.body }

          it { should have(8).items }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          its(:name) { should == "Item 0" }

          it { should include :Entity }
          it { should include :Link }
          it { should include :Property }

          describe "Entity" do
            subject { @catalog_item.body[:Entity] }
            let(:mock_data_catalog_item) { @mock_data.catalog_item_from_href(@catalog_item.body[:href]) }

            it { should have(3).items }

            its(:name) { should == mock_data_catalog_item.name }
            its(:type) { should == "application/vnd.vmware.vcloud.vAppTemplate+xml" }
            its(:href) { should == mock_data_catalog_item.vapp_template.href }
          end

          describe "Link" do
            subject { @catalog_item.body[:Link] }

            it { should have(4).items }

            its(:rel)  { should == "down" }
            its(:href) { should == mock_data_catalog_item.customization.href }
            its(:name) { should == mock_data_catalog_item.customization.name }
            its(:type) { should == "application/vnd.tmrk.ecloud.catalogItemCustomizationParameters+xml" }
          end
        end
      end

      context "with a catalog uri that doesn't exist" do
        subject { lambda { @vcloud.get_catalog(URI.parse('https://www.fakey.com/api/v0.8/vdc/999/catalog')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
