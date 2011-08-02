require 'spec'
require 'pp'

module Spec
  module Example
    module Subject
      module ExampleGroupMethods
        def its(attribute, &block)
          describe(attribute) do
            define_method(:subject) { s = super(); s.is_a?(Hash) ? s[attribute] : s.send(attribute) }
            it(&block)
          end
        end
      end
    end
  end
end

#Initialize this to a known seed
srand 1234

current_directory = File.dirname(__FILE__)
require "#{current_directory}/../../lib/fog"
require "#{current_directory}/../../lib/fog/core/bin"

Fog.mock! if ENV['FOG_MOCK']

require "#{current_directory}/../../lib/fog/vcloud/bin"

def arrayify(item)
  item.is_a?(Array) ? item : [ item ]
end

shared_examples_for "all responses" do
  it { should be_an_instance_of Excon::Response }
  it { should respond_to :body }
  it { should respond_to :headers }
  it { should have_at_least(1).body }
  it { should have_at_least(0).headers }
  its(:body) { should be_an_instance_of Hash }
  its(:headers) { should be_an_instance_of Hash }
end

shared_examples_for "all delete responses" do
  it { should be_an_instance_of Excon::Response }
  it { should respond_to :body }
  it { should respond_to :headers }
  its(:headers) { should be_an_instance_of Hash }
end

shared_examples_for "it has a Content-Type header" do
  its(:headers) { should include "Content-Type" }
end

shared_examples_for "all rel=down vcloud links" do
  it { should be_an_instance_of Struct::VcloudLink }
  specify { subject.rel.should == "down" }
end

shared_examples_for "all vcloud links w/o a rel" do
  it { should be_an_instance_of Struct::VcloudLink }
  specify { subject.rel.should == nil }
end

shared_examples_for "all vcloud catalog links" do
  specify { subject.type.should == "application/vnd.vmware.vcloud.catalog+xml" }
end

shared_examples_for "all tmrk ecloud publicIpList links" do
  specify { subject.type.should == "application/vnd.tmrk.ecloud.publicIpsList+xml" }
end

shared_examples_for "all tmrk ecloud firewallAclList links" do
  specify { subject.type.should == "application/vnd.tmrk.ecloud.firewallAclsList+xml" }
end

shared_examples_for "all tmrk ecloud internetServicesList links" do
  specify { subject.type.should == "application/vnd.tmrk.ecloud.internetServicesList+xml" }
end

shared_examples_for "all vcloud application/xml types" do
  specify { subject.type.should == "application/xml" }
end

shared_examples_for "a vapp type" do
  specify { subject.type.should == "application/vnd.vmware.vcloud.vApp+xml" }
end

shared_examples_for "all vcloud network types" do
  specify { subject.type.should == "application/vnd.vmware.vcloud.network+xml" }
end

shared_examples_for "all login requests" do

  it { should respond_to :login }

  describe "#login" do
    before { @login = @vcloud.login }
    subject { @login }

    it_should_behave_like "all responses"

    its(:headers) { should include "Set-Cookie" }

    describe "#body" do
      subject { @login.body }

      it { should have(4).items }
      it_should_behave_like "it has the standard vcloud v0.8 xmlns attributes"   # 3 keys
      it { should include(:Org) }

      describe ":Org" do
        subject { arrayify(@login.body[:Org]) }

        specify do
          subject.each do |org|
            org.should include(:type)
            org[:type].should be_of_type "application/vnd.vmware.vcloud.org+xml"
            org.should include(:name)
            org[:name].should be_an_instance_of String
            org.should include(:href)
            org[:href].should be_a_url
          end
        end
      end
    end
  end
end

shared_examples_for "it has a vcloud v0.8 xmlns" do
  its(:xmlns) { should == 'http://www.vmware.com/vcloud/v0.8' }
end

shared_examples_for "it has the proper xmlns_xsi" do
  its(:xmlns_xsi) { should == "http://www.w3.org/2001/XMLSchema-instance" }
end

shared_examples_for "it has the proper xmlns_xsd" do
  its(:xmlns_xsd) { should == "http://www.w3.org/2001/XMLSchema" }
end

shared_examples_for "it has the standard xmlns attributes" do
  it_should_behave_like "it has the proper xmlns_xsi"
  it_should_behave_like "it has the proper xmlns_xsd"
end

shared_examples_for "it has the standard vcloud v0.8 xmlns attributes" do
  it_should_behave_like "it has a vcloud v0.8 xmlns"
  it_should_behave_like "it has the standard xmlns attributes"
end

shared_examples_for "a request for a resource that doesn't exist" do
  it { should raise_error Excon::Errors::Unauthorized }
end

shared_examples_for "a vdc catalog link" do
  it_should_behave_like "all rel=down vcloud links"
  it_should_behave_like "all vcloud catalog links"
  its(:href) { should == URI.parse(@mock_vdc[:href] + "/catalog") }
end

shared_examples_for "a tmrk network link" do
  it_should_behave_like "all vcloud links w/o a rel"
  it_should_behave_like "all vcloud network types"
end

shared_examples_for "the mocked tmrk network links" do
  it { should have(2).networks }

  describe "[0]" do
    subject { @vdc.body.networks[0] }
    it_should_behave_like "a tmrk network link"
    its(:href) { should == URI.parse(@mock_vdc[:networks][0][:href]) }
    its(:name) { should == @mock_vdc[:networks][0][:name] }
  end

  describe "[1]" do
    subject { @vdc.body.networks[1] }
    it_should_behave_like "a tmrk network link"
    its(:href) { should == URI.parse(@mock_vdc[:networks][1][:href]) }
    its(:name) { should == @mock_vdc[:networks][1][:name] }
  end
end

shared_examples_for "the mocked tmrk resource entity links" do
  it { should have(3).resource_entities }

  describe "[0]" do
    subject { @vdc.body.resource_entities[0] }
    it_should_behave_like "a vapp type"
    it_should_behave_like "all vcloud links w/o a rel"
    its(:href) { should == URI.parse(@mock_vdc[:vms][0][:href]) }
    its(:name) { should == @mock_vdc[:vms][0][:name] }
  end
  describe "[1]" do
    subject { @vdc.body.resource_entities[1] }
    it_should_behave_like "a vapp type"
    it_should_behave_like "all vcloud links w/o a rel"
    its(:href) { should == URI.parse(@mock_vdc[:vms][1][:href]) }
    its(:name) { should == @mock_vdc[:vms][1][:name] }
  end
  describe "[2]" do
    subject { @vdc.body.resource_entities[2] }
    it_should_behave_like "a vapp type"
    it_should_behave_like "all vcloud links w/o a rel"
    its(:href) { should == URI.parse(@mock_vdc[:vms][2][:href]) }
    its(:name) { should == @mock_vdc[:vms][2][:name] }
  end
end

Spec::Example::ExampleGroupFactory.register(:mock_vcloud_request, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:mock_vcloud_model, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:mock_tmrk_ecloud_request, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:mock_tmrk_ecloud_model, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:vcloud_request, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:tmrk_ecloud_request, Class.new(Spec::Example::ExampleGroup))
Spec::Example::ExampleGroupFactory.register(:tmrk_vcloud_request, Class.new(Spec::Example::ExampleGroup))

def setup_generic_mock_data
  @mock_version = @mock_data.versions.first
  @mock_organization = @mock_data.organizations.first
  @mock_vdc = @mock_organization.vdcs.first
  @mock_vm = @mock_vdc.virtual_machines.first
  @mock_network = @mock_vdc.networks.first
end

def setup_ecloud_mock_data
  @base_url = Fog::Vcloud::Terremark::Ecloud::Mock.base_url
  @mock_data = Fog::Vcloud::Terremark::Ecloud::Mock.data
  setup_generic_mock_data
  @mock_vdc_service_collection = @mock_vdc.internet_service_collection
  @mock_public_ip_collection = @mock_vdc.public_ip_collection
  @mock_public_ip = @mock_public_ip_collection.items.first
  @mock_service_collection = @mock_public_ip.internet_service_collection
  @mock_service = @mock_service_collection.items.first
  @mock_node_collection = @mock_service.node_collection
  @mock_node = @mock_node_collection.items.first
  @mock_catalog = @mock_vdc.catalog
  @mock_catalog_item = @mock_catalog.items.first
  @mock_network_ip_collection = @mock_network.ip_collection
  @mock_network_ip = @mock_network_ip_collection.items.values.first
  @mock_network_extensions = @mock_network.extensions
end

def setup_vcloud_mock_data
  @base_url = Fog::Vcloud::Mock.base_url
  @mock_data = Fog::Vcloud::Mock.data
  setup_generic_mock_data
end

Spec::Runner.configure do |config|
  config.after(:all) do
    Fog::Vcloud::Mock.data_reset
  end

  config.before(:each, :type => :vcloud_request) do
    @vcloud = Fog::Vcloud::Terremark::Ecloud.new(Fog.credentials[:vcloud][:ecloud])
  end

  config.before(:all, :type => :mock_vcloud_model) do
    Fog::Vcloud::Mock.data_reset
    setup_vcloud_mock_data
    @vcloud = Fog::Vcloud.new(:username => "foo", :password => "bar", :versions_uri => "http://fakey.com/api/versions")
  end

  config.before(:all, :type => :mock_vcloud_request) do
    Fog::Vcloud::Mock.data_reset
    setup_vcloud_mock_data
    @vcloud = Fog::Vcloud.new(:username => "foo", :password => "bar", :versions_uri => "http://fakey.com/api/versions")
  end

  config.before(:each, :type => :mock_tmrk_ecloud_request) do
    Fog::Vcloud::Mock.data_reset
    Fog::Vcloud::Terremark::Ecloud::Mock.data_reset
    setup_ecloud_mock_data
    @vcloud = Fog::Vcloud::Terremark::Ecloud.new(:username => "foo", :password => "bar", :versions_uri => "http://fakey.com/api/versions", :module => "Fog::Vcloud::Terremark::Ecloud")
  end
  config.before(:each, :type => :mock_tmrk_ecloud_model) do
    Fog::Vcloud::Mock.data_reset
    Fog::Vcloud::Terremark::Ecloud::Mock.data_reset
    setup_ecloud_mock_data
    @vcloud = Fog::Vcloud::Terremark::Ecloud.new(:username => "foo", :password => "bar", :versions_uri => "http://fakey.com/api/versions", :module => "Fog::Vcloud::Terremark::Ecloud")
  end
end

Spec::Matchers.define :have_only_these_attributes do |expected|
  match do |actual|
    attributes = actual.instance_variable_get('@attributes')
    attributes.all? { |attribute| expected.include?(attribute) } && ( expected.length == attributes.length )
  end

  failure_message_for_should do |actual|
    msg = "Expected: [#{expected.map{|e| ":#{e}"}.join(", ")}]\n"
    msg += "Got: [#{actual.instance_variable_get('@attributes').map{|a| ":#{a}"}.join(", ")}]"
    msg
  end
end

Spec::Matchers.define :have_identity do |expected|
  match do |actual|
    actual.instance_variable_get('@identity').should == expected
  end

  failure_message_for_should do |actual|
    "Expected: '#{expected}', but got: '#{actual.instance_variable_get('@identity')}'"
  end
end

Spec::Matchers.define :have_members_of_the_right_model do
  match do |actual|
    actual.all? { |member| member.is_a?(actual.model) }
  end
end

Spec::Matchers.define :have_key_with_value do |expected_key, expected_value|
  match do |actual|
    actual.has_key?(expected_key) && actual[expected_key] == expected_value
  end
end

Spec::Matchers.define :have_key_with_array do |expected_key, expected_array|
  match do |actual|
    actual[expected_key].all? { |item| expected_array.include?(item) } && actual[expected_key].length == expected_array.length
  end
  failure_message_for_should do |actual|
    "Items not found in array:\n#{expected_array.select { |expected_item| !actual[expected_key].include?(expected_item) }.map { |item| item.inspect }.join("\n")}\n"  +
    "Orignal items:\n#{actual[expected_key].map { |item| item.inspect }.join("\n") }\n"+
    "Length Difference: #{expected_array.length - actual[expected_key].length}"
  end
end

Spec::Matchers.define :have_headers_denoting_a_content_type_of do |expected|
  match do |actual|
    actual.headers["Content-Type"] == expected
  end
end

Spec::Matchers.define :have_keys_with_values do |expected|
  match do |actual|
    actual.each_pair.all? do |key, value|
      expected.keys.include?(key) && expected[key] == value
    end
  end
end

Spec::Matchers.define :be_a_vapp_link_to do |expected|
  match do |actual|
    actual.is_a?(Hash) and
    actual[:type] == "application/vnd.vmware.vcloud.vApp+xml" and
    actual[:href] == expected.href and
    actual[:name] == expected.name
  end
end

Spec::Matchers.define :be_a_network_link_to do |expected|
  match do |actual|
    actual.is_a?(Hash) and
    actual[:type] == "application/vnd.vmware.vcloud.network+xml" and
    actual[:href] == expected.href and
    actual[:name] == expected.name
  end
end

Spec::Matchers.define :have_all_attributes_be_nil do
  match do |actual|
    actual.class.attributes.all? { |attribute| actual.send(attribute.to_sym) == nil }
  end
end

Spec::Matchers.define :be_a_url do
  match do |actual|
    actual.match(/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix)
  end
end

Spec::Matchers.define :be_either_a_hash_or_array  do
  match do |actual|
    actual.is_a?(Hash) || actual.is_a?(Array)
  end
end

Spec::Matchers.define :be_a_known_vmware_type do
  match do |actual|
    ["application/vnd.vmware.vcloud.org+xml"].include?(actual)
  end
end

Spec::Matchers.define :be_of_type do |type|
  match do |actual|
    actual == type ||
      if actual.is_a?(Hash) && actual[:type]
        actual[:type] == type
      end ||
      if actual.respond_to(:type)
        actual.type == type
      end
  end
end
