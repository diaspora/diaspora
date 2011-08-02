require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_catalog }

    describe "#get_catalog" do
      context "with a valid vdc catalog_uri" do
        before { @catalog = @vcloud.get_catalog(@mock_vdc.catalog.href) }
        subject { @catalog }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.catalog+xml" }

        describe "#body" do
          subject { @catalog.body }

          it { should have(7).items }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys

          its(:name) { should == @mock_vdc.catalog.name }

          it { should include :CatalogItems }

          describe "CatalogItems" do
            subject { @catalog.body[:CatalogItems] }

            it { should have(1).items }
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
