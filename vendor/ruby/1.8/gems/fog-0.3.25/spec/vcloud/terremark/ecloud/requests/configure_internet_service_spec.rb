require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud, initialized w/ the TMRK Ecloud module", :type => :mock_tmrk_ecloud_request do
    subject { @vcloud }

    it { should respond_to :configure_internet_service }

    describe "#configure_internet_service" do
      before do
        @original_service = @vcloud.get_internet_services(@mock_public_ip.internet_service_collection.href).body[:InternetService].first
        @ip_data = { :id => @mock_public_ip.object_id, :name => @mock_public_ip.name, :href => @mock_public_ip.href.to_s }
        @service_data = { :name => @original_service[:Name], :protocol => @original_service[:Protocol],
                          :port => @original_service[:Port], :description => @original_service[:Description],
                          :enabled => @original_service[:Enabled], :redirect_url => @original_service[:RedirectURL],
                          :id => @original_service[:Id], :href => @original_service[:Href], :timeout => @original_service[:Timeout] }
      end

      context "with a valid Internet Service uri and valid data" do
        subject { @vcloud.configure_internet_service(@original_service[:Href], @service_data, @ip_data) }

        it_should_behave_like "all responses"

        context "with some changed data" do
          before do
            @service_data[:description] = "TEST BOOM"
            @service_data[:redirect_url] = "http://google.com"
            @service_data[:port] = "80"
          end

          it "should change data" do
            @original_service[:Description].should == @mock_service[:description]
            @original_service[:RedirectURL].should == @mock_service[:redirect_url]
            @original_service[:Port].should == @mock_service[:port].to_s
            result = subject
            result.body[:Description].should == @service_data[:description]
            result.body[:RedirectURL].should == @service_data[:redirect_url]
            result.body[:Port].should        == @service_data[:port]

            new_result = @vcloud.get_internet_services(@mock_public_ip.internet_service_collection.href).body[:InternetService].first

            new_result[:Description].should == @service_data[:description]
            new_result[:RedirectURL].should == @service_data[:redirect_url]
            new_result[:Port].should        == @service_data[:port]
          end
        end
      end

      context "with an internet_services_uri that doesn't exist" do
        subject { lambda { @vcloud.configure_internet_service(URI.parse('https://www.fakey.c/piv8vc99'), @service_data, @ip_data ) } }

        it_should_behave_like "a request for a resource that doesn't exist"
      end
    end
  end
else
end

