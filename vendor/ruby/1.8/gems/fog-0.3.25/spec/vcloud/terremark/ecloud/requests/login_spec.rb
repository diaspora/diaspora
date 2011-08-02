require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it_should_behave_like "all login requests"
  end
else
end
