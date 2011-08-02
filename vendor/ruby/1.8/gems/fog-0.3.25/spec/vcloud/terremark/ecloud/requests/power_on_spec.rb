require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :power_on }

    describe :power_on, :type => :vcloud_request do
      context "with a valid vapp uri" do
        before { @mock_vm.power_off!; @power_on = @vcloud.power_on(@mock_vm.href(:power_on)) }
        subject { @power_on }

        it_should_behave_like "all responses"
        #it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.network+xml" }

        specify { @mock_vm.status.should == 4 }

        describe :body do
          subject { @power_on.body }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys
        end
      end

      context "with a vapp uri that doesn't exist" do
        subject { lambda { @vcloud.power_on(URI.parse('https://www.fakey.com/api/v0.8/vapp/9999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

