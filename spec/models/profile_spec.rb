#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Profile do
  describe 'validation' do
    describe "of first_name" do
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :first_name => "     Shelly    ")
        profile.should be_valid
        profile.first_name.should == "Shelly"
      end
      
      it "can be 32 characters long" do
        profile = Factory.build(:profile, :first_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end
      
      it "cannot be 33 characters" do
        profile = Factory.build(:profile, :first_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end
    end
    describe "of last_name" do
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :last_name => "     Ohba    ")
        profile.should be_valid
        profile.last_name.should == "Ohba"
      end
      
      it "can be 32 characters long" do
        profile = Factory.build(:profile, :last_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end
      
      it "cannot be 33 characters" do
        profile = Factory.build(:profile, :last_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end
    end
  end

  describe 'serialization' do
    let(:person) {Factory.create(:person)} 
   
    it 'should include persons diaspora handle' do
      xml = person.profile.to_diaspora_xml 

      xml.should include person.diaspora_handle
      xml.should_not include person.id.to_s
    end
  end
end
