require File.dirname(__FILE__) + '/../spec_helper'

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_vcloud_request do
    subject { @vcloud }

    it { should respond_to :get_organization }

    describe "#get_organization" do
      context "with a valid organization uri" do
        before { @organization = @vcloud.get_organization(@vcloud.default_organization_uri) }
        subject { @organization }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.org+xml" }

        describe "#body" do
          subject { @organization.body }


          let(:links) { subject[:Link] }

          it { should have(6).keys }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys
          it { should have_key_with_value :href, @mock_organization.href }
          it { should have_key_with_value :name, @mock_organization.name }
          it { should have_key_with_array :Link, @mock_organization.vdcs.map { |vdc|
                                                 [{ :type => "application/vnd.vmware.vcloud.vdc+xml",
                                                    :href => vdc.href,
                                                    :name => vdc.name,
                                                    :rel => "down" },
                                                  { :type => "application/vnd.vmware.vcloud.catalog+xml",
                                                    :href => vdc.catalog.href,
                                                    :name => vdc.catalog.name,
                                                    :rel => "down" },
                                                  { :type => "application/vnd.vmware.vcloud.tasksList+xml",
                                                    :href => vdc.task_list.href,
                                                    :name => vdc.task_list.name,
                                                    :rel => "down" }]
                                                  }.flatten }

        end
      end
      context "with an organization uri that doesn't exist" do
        subject { lambda { @vcloud.get_organization(URI.parse('https://www.fakey.com/api/v0.8/org/999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

