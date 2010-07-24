require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/diaspora/ostatus_generator'

describe Diaspora::OStatus do
  before do
    @user = Factory.create(:user) 
    Diaspora::OStatus::OWNER = @user
  end

  describe Diaspora::OStatus::Generate do

    describe "header" do
      it 'should generate an OStatus compliant header' do
        Diaspora::OStatus::Generate::headers(:current_url => @user.url).should include @user.url
      end
    end

    describe "status message entry" do
      before do
        @status_message = Factory.create(:status_message, :message => "feed me")
      end

      it "should encode to activity stream xml" do
        sm_entry = Diaspora::OStatus::generate(:objects => @status_message, :current_url => "http://diaspora.com/")
        sm_entry.should include(@status_message.message)
        sm_entry.should include('title')
      end

    end
  end

end
