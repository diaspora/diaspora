require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :get_nodes }

    describe "#get_nodes" do
      context "with a valid nodes_uri" do
        before { @nodes = @vcloud.get_nodes(@mock_node_collection.href) }
        subject { @nodes }

        it_should_behave_like "all responses"
        it { should have_headers_denoting_a_content_type_of "application/vnd.tmrk.ecloud.nodeService+xml" }

        describe "#body" do
          subject { @nodes.body }

          it { should have(3).items }

          describe "[:NodeService]" do
            subject { @nodes.body[:NodeService] }

            it { should have(@mock_node_collection.items.length).nodes }

            [0,1].each do |idx|

              context "[#{idx}]" do
                subject { @nodes.body[:NodeService][idx] }
                let(:mock_node) { @mock_node_collection.items[idx] }
                let(:keys) { subject.keys.sort_by(&:to_s) }
                specify { keys.should == [:Description, :Enabled, :Href, :Id, :IpAddress, :Name, :Port] }
                its(:Href) { should == mock_node.href }
                its(:Id) { should == mock_node.object_id.to_s }
                its(:Name) { should == mock_node.name }
                its(:Enabled) { should == mock_node.enabled.to_s }
                its(:Port) { should == mock_node.port.to_s }
                its(:IpAddress) { should == mock_node.ip_address }
                its(:Description) { should == mock_node.description }
              end

            end

          end

        end
      end

      context "with a public_ips_uri that doesn't exist" do
        subject { lambda { @vcloud.get_nodes(URI.parse('https://www.fakey.c/piv8vc99')) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end
