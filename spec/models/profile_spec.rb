# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Profile, :type => :model do
  describe 'validation' do
    describe "of first_name" do
      it "strips leading and trailing whitespace" do
        profile = FactoryGirl.build(:profile, :first_name => "     Shelly    ")
        expect(profile).to be_valid
        expect(profile.first_name).to eq("Shelly")
      end

      it "can be 32 characters long" do
        profile = FactoryGirl.build(:profile, :first_name => "Hexagoooooooooooooooooooooooooon")
        expect(profile).to be_valid
      end

      it "cannot be 33 characters" do
        profile = FactoryGirl.build(:profile, :first_name => "Hexagooooooooooooooooooooooooooon")
        expect(profile).not_to be_valid
      end

      it 'cannot have ;' do
        profile = FactoryGirl.build(:profile, :first_name => "Hex;agon")
        expect(profile).not_to be_valid
      end
    end

    describe 'from_omniauth_hash' do
      before do
        @from_omniauth = {'first_name' => 'bob', 'last_name' => 'jones', 'description' => 'this is my bio', 'location' => 'sf', 'image' => 'http://cats.com/gif.gif'}
      end

      it 'outputs a hash that can update a diaspora profile' do
        profile = Profile.new
        expect(profile.from_omniauth_hash(@from_omniauth)['bio']).to eq('this is my bio')
      end

      it 'does not overwrite any exsisting profile fields' do
        profile = Profile.new(:first_name => 'maxwell')
        expect(profile.from_omniauth_hash(@from_omniauth)['first_name']).to eq('maxwell')
      end

      it 'sets full name to first name' do
        @from_omniauth = {'name' => 'bob jones', 'description' => 'this is my bio', 'location' => 'sf', 'image' => 'http://cats.com/gif.gif'}

        profile = Profile.new
        expect(profile.from_omniauth_hash(@from_omniauth)['first_name']).to eq('bob jones')
      end
    end

    describe '#contruct_full_name' do
      it 'generates a full name given only first name' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = "casimiro"
        profile.last_name = nil

        expect(profile.full_name).not_to eq("casimiro")
        profile.save
        expect(profile.full_name).to eq("casimiro")
      end

      it 'generates a full name given only last name' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = nil
        profile.last_name = "grippi"

        expect(profile.full_name).not_to eq("grippi")
        profile.save
        expect(profile.full_name).to eq("grippi")
      end

      it 'generates a full name given first and last names' do
        profile = FactoryGirl.build(:person).profile
        profile.first_name = "casimiro"
        profile.last_name = "grippi"

        expect(profile.full_name).not_to eq("casimiro grippi")
        profile.save
        expect(profile.full_name).to eq("casimiro grippi")
      end
    end

    describe "of last_name" do
      it "strips leading and trailing whitespace" do
        profile = FactoryGirl.build(:profile, :last_name => "     Ohba    ")
        expect(profile).to be_valid
        expect(profile.last_name).to eq("Ohba")
      end

      it "can be 32 characters long" do
        profile = FactoryGirl.build(:profile, :last_name => "Hexagoooooooooooooooooooooooooon")
        expect(profile).to be_valid
      end

      it "cannot be 33 characters" do
        profile = FactoryGirl.build(:profile, :last_name => "Hexagooooooooooooooooooooooooooon")
        expect(profile).not_to be_valid
      end

      it 'cannot have ;' do
        profile = FactoryGirl.build(:profile, :last_name => "Hex;agon")
        expect(profile).not_to be_valid
      end
      it 'disallows ; with a newline in the string' do
        profile = FactoryGirl.build(:profile, :last_name => "H\nex;agon")
        expect(profile).not_to be_valid
      end
    end
  end

  describe "of location" do
    it "can be 255 characters long" do
      profile = FactoryGirl.build(:profile, :location => "a"*255)
      expect(profile).to be_valid
    end

    it "cannot be 256 characters" do
      profile = FactoryGirl.build(:profile, :location => "a"*256)
      expect(profile).not_to be_valid
    end
  end

  describe "image_url setters" do
    %i(image_url image_url_small image_url_medium).each do |method|
      describe "##{method}=" do
        before do
          @profile = FactoryGirl.build(:profile)
          @profile.public_send("#{method}=", "http://tom.joindiaspora.com/images/user/tom.jpg")
          @pod_url = AppConfig.pod_uri.to_s.chomp("/")
        end

        it "saves nil when setting nil" do
          @profile.public_send("#{method}=", nil)
          expect(@profile[method]).to be_nil
        end

        it "saves nil when setting an empty string" do
          @profile.public_send("#{method}=", "")
          expect(@profile[method]).to be_nil
        end

        it "makes relative urls absolute" do
          @profile.public_send("#{method}=", "/relative/url")
          expect(@profile.public_send(method)).to eq("#{@pod_url}/relative/url")
        end

        it "doesn't change absolute urls" do
          @profile.public_send("#{method}=", "http://not/a/relative/url")
          expect(@profile.public_send(method)).to eq("http://not/a/relative/url")
        end

        it "saves the default-url as nil" do
          @profile.public_send("#{method}=", "/assets/user/default.png")
          expect(@profile[method]).to be_nil
        end
      end
    end
  end

  describe '#image_url' do
    before do
      @profile = FactoryGirl.build(:profile)
    end

    it 'returns a default rather than nil' do
      @profile.image_url = nil
      expect(@profile.image_url).not_to be_nil
    end

    it 'falls back to the large thumbnail if the small thumbnail is nil' do
      #Backwards compatibility
      @profile[:image_url] = 'large'
      @profile[:image_url_small] = nil
      @profile[:image_url_medium] = nil
      expect(@profile.image_url(:thumb_small)).to eq('large')
      expect(@profile.image_url(:thumb_medium)).to eq('large')
    end
  end

  describe '#subscribers' do
    it 'returns all non-pending contacts for a user' do
      expect(bob.profile.subscribers.map(&:id)).to match_array([alice.person, eve.person].map(&:id))
    end
  end

  describe "public?" do
    it "is public if public_details is true" do
      profile = FactoryGirl.build(:profile, public_details: true)
      expect(profile.public?).to be_truthy
    end

    it "is not public if public_details is false" do
      profile = FactoryGirl.build(:profile, public_details: false)
      expect(profile.public?).to be_falsey
    end
  end

  describe 'date=' do
    let(:profile) { FactoryGirl.build(:profile) }

    it 'accepts form data' do
      profile.birthday = nil
      profile.date = { 'year' => '2000', 'month' => '01', 'day' => '01' }
      expect(profile.birthday.year).to eq(2000)
      expect(profile.birthday.month).to eq(1)
      expect(profile.birthday.day).to eq(1)
    end

    it 'unsets the birthday' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '', 'month' => '', 'day' => ''}
      expect(profile.birthday).to eq(nil)
    end

    it 'does not change with blank  month and day values' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      expect(profile.birthday.year).to eq(2000)
      expect(profile.birthday.month).to eq(1)
      expect(profile.birthday.day).to eq(1)
    end

    it 'does not accept blank initial values' do
      profile.birthday = nil
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      expect(profile.birthday).to eq(nil)
    end

    it 'does not accept invalid dates' do
      profile.birthday = nil
      profile.date = { 'year' => '2001', 'month' => '02', 'day' => '31' }
      expect(profile.birthday).to eq(nil)
    end

    it 'does not change with invalid dates' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '2001', 'month' => '02', 'day' => '31' }
      expect(profile.birthday.year).to eq(2000)
      expect(profile.birthday.month).to eq(1)
      expect(profile.birthday.day).to eq(1)
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

      expect(@object).to be_valid
    end
    it 'strips more than 5 tags' do
      @object.tag_string = '#one #two #three #four #five #six'
      @object.save
      expect(@object.tags.count).to eq(5)
    end
    it 'should require tag name not be more than 255 characters long' do
      @object.tag_string = "##{'a' * (255+1)}"
      @object.save
      expect(@object).not_to be_valid
    end
    it_should_behave_like 'it is taggable'
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
        expect(@profile[attr.to_sym]).to be_blank
      }
    end

    it 'removes all the tags from the profile' do
      expect(@profile.taggings).to receive(:delete_all)
      @profile.tombstone!
    end

    it "doesn't recreate taggings if tag string was requested" do
      @profile.tag_string
      @profile.tombstone!
      expect(@profile.taggings).to be_empty
    end
  end

  describe "#clearable_fields" do
    it 'returns the current profile fields' do
      profile = FactoryGirl.build :profile
      expect(profile.send(:clearable_fields).sort).to eq(
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
       "public_details",
       "full_name"].sort
      )
    end
  end
end
