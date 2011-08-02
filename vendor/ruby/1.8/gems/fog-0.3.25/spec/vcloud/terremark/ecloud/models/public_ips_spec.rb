require File.join(File.dirname(__FILE__),'..','..','..','spec_helper')

if Fog.mocking?
  describe "Fog::Vcloud::Terremark::Ecloud::PublicIps", :type => :mock_tmrk_ecloud_model do
    subject { @vcloud }

    it { should respond_to :public_ips }

    describe :class do
      subject { @vcloud.public_ips.class }
      its(:model)       { should == Fog::Vcloud::Terremark::Ecloud::PublicIp }
    end

    describe :public_ips do
      subject { @vcloud.vdcs[0].public_ips }
      it { should_not respond_to :create }

      it { should be_an_instance_of Fog::Vcloud::Terremark::Ecloud::PublicIps }

      its(:length) { should == 3 }

      it { should have_members_of_the_right_model }
    end
  end
else
end

