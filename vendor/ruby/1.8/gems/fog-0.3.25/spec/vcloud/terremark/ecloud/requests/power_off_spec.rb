require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :power_off }

    describe :power_off, :type => :vcloud_request do
      context "with a valid vapp uri" do
        before { @mock_vm.power_on!; @power_off = @vcloud.power_off(@mock_vm.href(:power_off)) }
        subject { @power_off }

        it_should_behave_like "all responses"
        #it { should have_headers_denoting_a_content_type_of "application/vnd.vmware.vcloud.network+xml" }

        specify { @mock_vm.status.should == 2 }

        describe :body do
          subject { @power_off.body }

          it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys
        end
      end

      context "with a vapp uri that doesn't exist" do
        subject { lambda { @vcloud.power_off(URI.parse('https://www.fakey.com/api/v0.8/vapp/9999')) } }
        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

