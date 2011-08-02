require File.join(File.dirname(__FILE__),'..','..','..','spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud::Terremark::Ecloud::InternetServices", :type => :mock_tmrk_ecloud_model do
    context "as an attribute of a VDC" do
      subject { @vcloud.vdcs[0] }

      it { should respond_to :internet_services }

      describe :class do
        subject { @vcloud.vdcs[0].internet_services.class }
        its(:model)       { should == Fog::Vcloud::Terremark::Ecloud::InternetService }
      end

      describe :internet_services do
        subject { @vcloud.vdcs[0].internet_services }

        it { should respond_to :create }

        it { should be_an_instance_of Fog::Vcloud::Terremark::Ecloud::InternetServices }

        its(:length) { should == 4 }

        it { should have_members_of_the_right_model }
      end
    end
  end
else
end
