#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Profile do
  describe 'validation' do
    describe "of first_name" do
      it "strips leading and trailing whitespace" do
        profile = FactoryGirl.build(:profile, :first_name => "     Shelly    ")
        profile.should be_valid
        profile.first_name.should == "Shelly"
      end

      it "can be 32 characters long" do
        profile = FactoryGirl.build(:profile, :first_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end

      it "cannot be 33 characters" do
        profile = FactoryGirl.build(:profile, :first_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end

      it 'cannot have ;' do
        profile = FactoryGirl.build(:profile, :first_name => "Hex;agon")
        profile.should_not be_valid
      end
    end

    describe 'from_omniauth_hash' do
      before do
        @from_omniauth = {'first_name' => 'bob', 'last_name' => 'jones', 'description' => 'this is my bio', 'location' => 'sf', 'image' => 'http://cats.com/gif.gif'}
      end

      it 'outputs a hash that can update a diaspora profile' do
        profile = Profile.new
        profile.from_omniauth_hash(@from_omniauth)['bio'].should == 'this is my bio'
      end

      it 'does not overwrite any exsisting profile fields' do
        profile = Profile.new(:first_name => 'maxwell')
        profile.from_omniauth_hash(@from_omniauth)['first_name'].should == 'maxwell'
      end

      it 'sets full name to first name' do
        @from_omniauth = {'name' => 'bob jones', 'description' => 'this is my bio', 'location' => 'sf', 'image' => 'http://cats.com/gif.gif'}
        
        profile = Profile.new
        profile.from_omniauth_hash(@from_omniauth)['first_name'].should == 'bob jones'
      end
    end

    describe '#contruct_full_name' do
      it 'generates a full name given only first name' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = "casimiro"
        profile.last_name = nil

        profile.full_name.should_not == "casimiro"
        profile.save
        profile.full_name.should == "casimiro"
      end

      it 'generates a full name given only last name' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = nil
        profile.last_name = "grippi"

        profile.full_name.should_not == "grippi"
        profile.save
        profile.full_name.should == "grippi"
      end

      it 'generates a full name given first and last names' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = "casimiro"
        profile.last_name = "grippi"

        profile.full_name.should_not == "casimiro grippi"
        profile.save
        profile.full_name.should == "casimiro grippi"
      end
    end

    describe "of last_name" do
      it "strips leading and trailing whitespace" do
        profile = FactoryGirl.build(:profile, :last_name => "     Ohba    ")
        profile.should be_valid
        profile.last_name.should == "Ohba"
      end

      it "can be 32 characters long" do
        profile = FactoryGirl.build(:profile, :last_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end

      it "cannot be 33 characters" do
        profile = FactoryGirl.build(:profile, :last_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end

      it 'cannot have ;' do
        profile = FactoryGirl.build(:profile, :last_name => "Hex;agon")
        profile.should_not be_valid
      end
      it 'disallows ; with a newline in the string' do
        profile = FactoryGirl.build(:profile, :last_name => "H\nex;agon")
        profile.should_not be_valid
      end
    end
  end

  describe '#image_url=' do
    before do
      @profile = FactoryGirl.build(:profile)
      @profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
      @pod_url = AppConfig.pod_uri.to_s.chomp("/")
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
      @profile = FactoryGirl.build(:profile)
      @profile.tag_string = '#big #rafi #style'
      xml = @profile.to_xml

      new_profile = Profile.from_xml(xml.to_s)
      new_profile.tag_string.should_not be_blank
      new_profile.tag_string.should include('#rafi')
    end
  end
  
  describe 'serialization' do
    let(:person) {FactoryGirl.build(:person,:diaspora_handle => "foobar" )}

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
      @profile = FactoryGirl.build(:profile)
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
      bob.profile.subscribers(bob).map{|s| s.id}.should =~ [alice.person, eve.person].map{|s| s.id}
    end
  end

  describe 'date=' do
    let(:profile) { FactoryGirl.build(:profile) }

    it 'accepts form data' do
      profile.birthday = nil
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

    it 'does not accept blank initial values' do
      profile.birthday = nil
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      profile.birthday.should == nil
    end

    it 'does not accept invalid dates' do
      profile.birthday = nil
      profile.date = { 'year' => '2001', 'month' => '02', 'day' => '31' }
      profile.birthday.should == nil
    end

    it 'does not change with invalid dates' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '2001', 'month' => '02', 'day' => '31' }
      profile.birthday.year.should == 2000
      profile.birthday.month.should == 1
      profile.birthday.day.should == 1
    end
  end

  describe 'tags' do
    before do
      person = FactoryGirl.build(:person)
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

  describe '#formatted_birthday' do
    before do
      @profile = FactoryGirl.build(:profile)
      @profile_hash =  { 'year' => '2000', 'month' => '01', 'day' => '01' }
      @profile.date = @profile_hash
    end

    it 'returns a formatted date' do
      @profile.formatted_birthday.should == "January  1, 2000"
    end

    it 'removes nil year birthdays' do
      @profile_hash.delete('year')
      @profile.date = @profile_hash
      @profile.formatted_birthday.should == 'January  1'
    end

    it 'retuns nil if no birthday is set' do
      @profile.date = {}
      @profile.formatted_birthday.should == nil
    end

  end

  describe '#receive' do
    it 'updates the profile in place' do
      local_luke, local_leia, remote_raphael = set_up_friends
      new_profile = FactoryGirl.build :profile
      lambda{
        new_profile.receive(local_leia, remote_raphael)
      }.should_not change(Profile, :count)
      remote_raphael.last_name.should == new_profile.last_name
    end

  end

  describe "#tombstone!" do
    before do
      @profile = bob.person.profile
    end
    it "clears the profile fields" do
      attributes = @profile.send(:clearable_fields)

      @profile.tombstone!
      @profile.reload
      attributes.each{ |attr|
        @profile[attr.to_sym].should be_blank
      }
    end

    it 'removes all the tags from the profile' do
      @profile.taggings.should_receive(:delete_all)
      @profile.tombstone!
    end
  end

  describe "#clearable_fields" do
    it 'returns the current profile fields' do
      profile = FactoryGirl.build :profile
      profile.send(:clearable_fields).sort.should == 
      ["diaspora_handle",
      "first_name",
      "last_name",
      "image_url",
      "image_url_small",
      "image_url_medium",
      "birthday",
      "gender",
      "bio",
      "searchable",
      "nsfw",
      "location",
      "full_name"].sort
    end
  end
end
