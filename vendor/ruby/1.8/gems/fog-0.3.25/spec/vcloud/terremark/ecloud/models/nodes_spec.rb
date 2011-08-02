require File.join(File.dirname(__FILE__),'..','..','..','spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud::Terremark::Ecloud::InternetServices", :type => :mock_tmrk_ecloud_model do
    context "as an attribute of an internet_service" do
      subject { @vcloud.vdcs.first.public_ips.first.internet_services.first }

      it { should respond_to :nodes }

      describe :class do
        subject { @vcloud.vdcs.first.public_ips.first.internet_services.first.nodes.class }
        its(:model)       { should == Fog::Vcloud::Terremark::Ecloud::Node }
      end

      describe :nodes do
        subject { @vcloud.vdcs.first.public_ips.first.internet_services.first.nodes }

        it { should respond_to :create }

        it { should be_an_instance_of Fog::Vcloud::Terremark::Ecloud::Nodes }

        its(:length) { should == 3 }

        it { should have_members_of_the_right_model }
      end
    end
  end
else
end
