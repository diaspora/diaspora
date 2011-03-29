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
      it 'cannot have ;' do
        profile = Factory.build(:profile, :first_name => "Hex;agon")
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

      it 'cannot have ;' do
        profile = Factory.build(:profile, :last_name => "Hex;agon")
        profile.should_not be_valid
      end
      it 'disallows ; with a newline in the string' do
        profile = Factory.build(:profile, :last_name => "H\nex;agon")
        profile.should_not be_valid
      end
    end
  end

  describe '#image_url=' do
    before do
      @profile = Factory.build(:profile)
      @profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
      @pod_url = (AppConfig[:pod_url][-1,1] == '/' ? AppConfig[:pod_url].chop : AppConfig[:pod_url])
    end
    it 'ignores an empty string' do
      lambda {@profile.image_url = ""}.should_not change(@profile, :image_url)
    end
    it 'makes relative urls absolute' do
      @profile.image_url = "/relative/url"
      @profile.image_url.should == "#{@pod_url}/relative/url"
    end
    it "doesn't change absolute urls" do
      @profile.image_url = "http://not/a/relative/url"
      @profile.image_url.should == "http://not/a/relative/url"
    end
  end

  describe '#from_xml' do
    it 'should make a valid profile object' do
      
      @profile = Factory.build(:profile)
      @profile.tag_string = '#big #rafi #style'
      xml = @profile.to_xml

      new_profile = Profile.from_xml(xml.to_s)
      new_profile.tag_string.should_not be_blank
      new_profile.tag_string.should include('#rafi')
    end
  end
  
  describe 'serialization' do
    let(:person) {Factory.create(:person,:diaspora_handle => "foobar" )}

    it 'should include persons diaspora handle' do
      xml = person.profile.to_diaspora_xml
      xml.should include "foobar"
    end

    it 'includes tags' do
      person.profile.tag_string = '#one'
      person.profile.build_tags
      person.profile.save
      xml = person.profile.to_diaspora_xml
      xml.should include "#one"
    end
    
    it 'includes location' do
      person.profile.location = 'Dark Side, Moon'
      person.profile.save
      xml = person.profile.to_diaspora_xml
      xml.should include "Dark Side, Moon"
    end
  end

  describe '#image_url' do
    before do
      @profile = Factory.build(:profile)
    end
    it 'returns a default rather than nil' do
      @profile.image_url = nil
      @profile.image_url.should_not be_nil
    end
    it 'falls back to the large thumbnail if the small thumbnail is nil' do
      #Backwards compatibility
      @profile[:image_url] = 'large'
      @profile[:image_url_small] = nil
      @profile[:image_url_medium] = nil
      @profile.image_url(:thumb_small).should == 'large'
      @profile.image_url(:thumb_medium).should == 'large'
    end
  end

  describe '#subscribers' do
    it 'returns all non-pending contacts for a user' do
      user = Factory(:user)
      aspect = user.aspects.create(:name => "zord")
      person = Factory.create(:person)
      user.activate_contact(person, Aspect.where(:id => aspect.id).first)

      person2 = Factory.create(:person)
      user.activate_contact(person2, Aspect.where(:id => aspect.id).first)

      user.profile.subscribers(user).map{|s| s.id}.should =~ [person, person2].map{|s| s.id}
    end
  end

  describe 'date=' do
    let(:profile) { Factory.build(:profile) }

    it 'accepts form data' do
      profile.birthday.should == nil
      profile.date = { 'year' => '2000', 'month' => '01', 'day' => '01' }
      profile.birthday.year.should == 2000
      profile.birthday.month.should == 1
      profile.birthday.day.should == 1
    end

    it 'unsets the birthday' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '', 'month' => '', 'day' => ''}
      profile.birthday.should == nil
    end

    it 'does not change with blank  month and day values' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      profile.birthday.year.should == 2000
      profile.birthday.month.should == 1
      profile.birthday.day.should == 1
    end

    it 'accepts blank initial vallues' do
      profile.birthday.should == nil
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      profile.birthday.should == nil
    end
  end

  describe 'tags' do
    before do
      person = Factory.create(:person)
      @object = person.profile
    end
    it 'allows 5 tags' do
      @object.tag_string = '#one #two #three #four #five'

      @object.valid?
      @object.errors.full_messages

      @object.should be_valid
    end
    it 'strips more than 5 tags' do
      @object.tag_string = '#one #two #three #four #five #six'
      @object.save
      @object.tags.count.should == 5
    end
    it_should_behave_like 'it is taggable'
  end

  describe '#receive' do
    
    it 'updates the profile in place' do
      local_luke, local_leia, remote_raphael = set_up_friends
      new_profile = Factory.build :profile
      lambda{
        new_profile.receive(local_leia, remote_raphael)
      }.should_not change(Profile, :count)
      remote_raphael.last_name.should == new_profile.last_name
    end

  end
end
