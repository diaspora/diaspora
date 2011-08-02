require File.join(File.dirname(__FILE__), '..', 'spec_helper')

shared_examples_for "real or mock get_versions requests" do

  subject { @vcloud }

  it { should respond_to :get_versions }

  describe "#get_versions" do
    subject { @vcloud.get_versions( @vcloud.versions_uri ) }

    it_should_behave_like "all responses"

    describe "body" do
      subject { @vcloud.get_versions( @vcloud.versions_uri ).body }

      it { should have(4).keys }
      it_should_behave_like "it has the standard xmlns attributes"   # 2 keys

      its(:xmlns) { should == "http://www.vmware.com/vcloud/versions" }

      its(:VersionInfo) { should be_either_a_hash_or_array }

      describe ":VersionInfo" do
        subject { arrayify(@vcloud.get_versions( @vcloud.versions_uri ).body[:VersionInfo]) }

        specify {
          subject.each do |version_info|
            version_info.should include(:LoginUrl)
            version_info[:LoginUrl].should be_a_url
            version_info.should include(:Version)
            version_info[:Version].should be_an_instance_of String
          end
        }
      end
    end
  end
end

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_vcloud_request do

    it_should_behave_like "real or mock get_versions requests"

    describe "body" do
      subject { @vcloud.get_versions( @vcloud.versions_uri ).body }
      its(:VersionInfo) { should == { :LoginUrl => @mock_version.login_url , :Version => @mock_version.version } }
    end
  end
else
  describe Fog::Vcloud, :type => :vcloud_request do
    it_should_behave_like "real or mock get_versions requests"
  end
end
