require File.dirname(__FILE__) + '/../spec_helper'

describe "XML generation" do

  describe "header" do
    it 'should generate an OStatus compliant header' do
      user = Factory.create(:user)
      Diaspora::XML::generate_headers.should include user.url
    end
  end


  describe "status message entry" do
    before do
      @status_message = Factory.build(:status_message)
    end

    it "should encode to activity stream xml" do
      Factory.create(:user)
      sm_entry = Diaspora::XML::generate(:objects => @status_message)
      sm_entry.should include(@status_message.message)
      sm_entry.should include('title')

      puts sm_entry
    end

  end


end
