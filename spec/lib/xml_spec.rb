require File.dirname(__FILE__) + '/../spec_helper'

describe Diaspora::XML do
  before do
    @user = Factory.create(:user) 
    Diaspora::XML::OWNER = @user
  end

  describe Diaspora::XML::Generate do

    describe "header" do
      it 'should generate an OStatus compliant header' do
        Diaspora::XML::Generate::headers(:current_url => @user.url).should include @user.url
      end
    end

    describe "status message entry" do
      before do
        @status_message = Factory.create(:status_message, :message => "feed me")
      end

      it "should encode to activity stream xml" do
        sm_entry = Diaspora::XML::generate(:objects => @status_message, :current_url => "http://diaspora.com/")
        sm_entry.should include(@status_message.message)
        sm_entry.should include('title')
      end

    end
  end

end
