require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_customization_options }

    describe "#get_customization_options" do
      context "with a valid catalog_item customizations uri" do
        let(:catalog_item) { @vcloud.get_catalog_item(@vcloud.vdcs.first.catalog.first.href) }

        before { @customization_options = @vcloud.get_customization_options(catalog_item.body[:Link][:href]) }
        subject { @customization_options }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.catalogItemCustomizationParameters+xml" }

        describe "#body" do
          subject { @customization_options.body }

          it { should have(5).items }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          specify { subject[:CustomizeNetwork].should == "true" }
          specify { subject[:CustomizePassword].should == "false" }
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
