require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :configure_node }

    describe "#configure_node" do
      let(:original_node) { @vcloud.get_node(@mock_node.href).body }
      let(:node_data) { { :name => "TEST BOOM", :enabled => "false", :description => "TEST BOOM DESC" } }

      context "with a valid node service uri" do

        subject { @vcloud.configure_node(@mock_node.href,node_data) }

        it_should_behave_like "all responses"

        describe "#body" do
          subject { @vcloud.configure_node(@mock_node.href,node_data).body }

          #Stuff that shouldn't change
          its(:Href) { should == @mock_node.href }
          its(:Id) { should == @mock_node.object_id.to_s }
          its(:Port) { should == @mock_node.port.to_s }
          its(:IpAddress) { should == @mock_node.ip_address }

          #Stuff that should change
          it "should change the name" do
            expect { subject }.to change { @vcloud.get_node(@mock_node.href).body[:Name] }.to(node_data[:name])
          end

          it "should change enabled" do
            expect { subject }.to change { @vcloud.get_node(@mock_node.href).body[:Enabled] }.to(node_data[:enabled])
          end

          it "should change the description" do
            expect { subject }.to change { @vcloud.get_node(@mock_node.href).body[:Description] }.to(node_data[:description])
          end
        end

      end

      context "with a nodes uri that doesn't exist" do
        subject { lambda { @vcloud.configure_node(URI.parse('https://www.fakey.c/piv8vc99'), node_data) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
