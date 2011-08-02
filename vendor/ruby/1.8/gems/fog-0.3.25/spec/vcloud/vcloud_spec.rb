require File.dirname(__FILE__) + '/spec_helper'

if Fog.mocking?
  describe Fog::Vcloud, :type => :mock_vcloud_request do
    subject { Fog::Vcloud.new(:username => "foo", :password => "bar", :versions_uri => "https://fakey.com/api/versions") }

    it { should be_an_instance_of Fog::Vcloud::Mock }

    it { should respond_to :default_organization_uri }

    it { should respond_to :supported_versions }

    it { should have_at_least(1).supported_versions }

    its(:default_organization_uri) { should == @mock_organization.href }

  end
end
