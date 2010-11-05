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

  describe '#image_url=' do
    before do
      @user = make_user
      @profile = @user.person.profile
      fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
      @photo = @user.post(:photo, :user_file => File.open(fixture_name), :to => 'all')
      @profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
      @pod_url = (APP_CONFIG[:pod_url][-1,1] == '/' ? APP_CONFIG[:pod_url].chop : APP_CONFIG[:pod_url])
    end
    it 'ignores an empty string' do
      lambda {@profile.image_url = ""}.should_not change(@profile, :image_url)
    end
    it 'makes relative urls absolute' do
      @profile.image_url = @photo.url(:thumb_medium)
      @profile.image_url.should == "#{@pod_url}#{@photo.url(:thumb_medium)}"
    end
    it 'accepts absolute urls' do
      @profile.image_url = "#{@pod_url}#{@photo.url(:thumb_medium)}"
      @profile.image_url.should == "#{@pod_url}#{@photo.url(:thumb_medium)}"
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
