# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Person, :type => :model do
  before do
    @user = bob
    @person = FactoryGirl.create(:person)
  end

  it 'always has a profile' do
    expect(Person.new.profile).not_to be_nil
  end

  it 'does not save automatically' do
    expect(Person.new.persisted?).to be false
    expect(Person.new.profile.persisted?).to be false
  end

  context 'scopes' do
    describe '.for_json' do
      it 'does not select public keys' do
        expect {
          Person.for_json.first.serialized_public_key
        }.to raise_error ActiveModel::MissingAttributeError
      end
    end

    describe '.local' do
      it 'returns only local people' do
        Person.local =~ [@person]
      end
    end

    describe '.remote' do
      it 'returns only local people' do
        Person.remote =~ [@user.person]
      end
    end

    describe '.find_person_from_guid_or_username' do
      it 'searchs for a person if id is passed' do
        expect(Person.find_from_guid_or_username(:id => @person.guid).id).to eq(@person.id)
      end

      it 'searchs a person from a user if username is passed' do
        expect(Person.find_from_guid_or_username(:username => @user.username).id).to eq(@user.person.id)
      end

      it 'throws active record not found exceptions if no person is found via id' do
        expect{
          Person.find_from_guid_or_username(:id => "2d13123")
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'throws active record not found exceptions if no person is found via username' do
        expect{
          Person.find_from_guid_or_username(:username => 'michael_jackson')
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '.all_from_aspects' do
      it "pulls back the right people given all a user's aspects" do
        aspect_ids = bob.aspects.map(&:id)
        expect(Person.all_from_aspects(aspect_ids, bob).map(&:id)).to match_array(bob.contacts.includes(:person).map{|c| c.person.id})
      end

      it "pulls back the right people given a subset of aspects" do
        aspect_ids = bob.aspects.first.id
        expect(Person.all_from_aspects(aspect_ids, bob).map(&:id)).to match_array(bob.aspects.first.contacts.includes(:person).map{|c| c.person.id})
      end

      it "respects aspects given a user" do
        aspect_ids = alice.aspects.map(&:id)
        expect(Person.all_from_aspects(aspect_ids, bob).map(&:id)).to eq([])
      end
    end

    describe ".who_have_reshared a user's posts" do
      it 'pulls back users who reshared the status message of a user' do
        sm = FactoryGirl.create(:status_message, :author => alice.person, :public => true)
        reshare = FactoryGirl.create(:reshare, :root => sm)
        expect(Person.who_have_reshared_a_users_posts(alice)).to eq([reshare.author])
      end
    end

    describe ".find_by_substring" do
      it "returns \"none\" when the substring is less than 1 non-space character" do
        expect(Person.find_by_substring("R")).to eq(Person.none)
        expect(Person.find_by_substring("R  ")).to eq(Person.none)
        expect(Person.find_by_substring("")).to eq(Person.none)
        expect(Person.find_by_substring("  ")).to eq(Person.none)
      end

      it "finds a person with a profile name containing the substring" do
        substring = r_str
        person = FactoryGirl.create(:person, first_name: "A#{substring}A")
        expect(Person.find_by_substring(substring)).to include(person)
      end

      it "finds a person with a diaspora ID starting with the substring" do
        substring = r_str
        person = FactoryGirl.create(:person, diaspora_handle: "#{substring}A@pod.tld")
        expect(Person.find_by_substring(substring)).to include(person)
      end
    end

    describe ".allowed_to_be_mentioned_in_a_comment_to" do
      let(:status_bob) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }

      it "returns the author and people who have commented or liked the private post" do
        kate = FactoryGirl.create(:user_with_aspect, friends: [bob])
        olga = FactoryGirl.create(:user_with_aspect, friends: [bob])
        alice.comment!(status_bob, "why so formal?")
        eve.comment!(status_bob, "comment text")
        kate.like!(status_bob)
        olga.participate!(status_bob)
        expect(
          Person.allowed_to_be_mentioned_in_a_comment_to(status_bob).ids
        ).to match_array([alice, bob, eve, kate].map(&:person_id))
      end

      it "selects distinct people" do
        alice.comment!(status_bob, "hi")
        alice.comment!(status_bob, "how are you?")
        expect(
          Person.allowed_to_be_mentioned_in_a_comment_to(status_bob).ids
        ).to match_array([alice, bob].map(&:person_id))
      end

      it "returns all for public posts" do
        status_bob.update(public: true) # set parent public
        expect(Person.allowed_to_be_mentioned_in_a_comment_to(status_bob).ids).to match_array(Person.ids)
      end
    end

    describe ".sort_for_mention_suggestion" do
      let(:status_message) { FactoryGirl.create(:status_message) }

      it "returns people sorted in the order: post author > commenters > likers > contacts" do
        like = FactoryGirl.create(:like, target: status_message)
        comment = FactoryGirl.create(:comment, post: status_message)
        current_user = FactoryGirl.create(:user_with_aspect, friends: [alice])
        result = Person.select(:id, :guid).sort_for_mention_suggestion(status_message, current_user)
        expect(result[0]).to eq(status_message.author)
        expect(result[1]).to eq(comment.author)
        expect(result[2]).to eq(like.author)
        expect(result[3]).to eq(alice.person) # a contact of the current user
      end

      it "sorts people of the same priority by profile name" do
        current_user = FactoryGirl.create(:user_with_aspect)
        person1 = FactoryGirl.create(:person, first_name: "x2")
        person2 = FactoryGirl.create(:person, first_name: "x1")
        result = Person
                 .select(:id, :guid)
                 .where(id: [person1.id, person2.id])
                 .sort_for_mention_suggestion(status_message, current_user)
        expect(result[0].id).to eq(person2.id)
        expect(result[1].id).to eq(person1.id)
      end

      it "sorts people of the same priority and same names by diaspora ID" do
        current_user = FactoryGirl.create(:user_with_aspect)
        person1 = FactoryGirl.create(:person, diaspora_handle: "x2@pod.tld")
        person1.profile.update(first_name: "John", last_name: "Doe")
        person2 = FactoryGirl.create(:person, diaspora_handle: "x1@pod.tld")
        person2.profile.update(first_name: "John", last_name: "Doe")
        result = Person
                 .select(:id, :guid)
                 .where(id: [person1.id, person2.id])
                 .sort_for_mention_suggestion(status_message, current_user)
        expect(result[0].id).to eq(person2.id)
        expect(result[1].id).to eq(person1.id)
      end
    end

    describe ".in_aspects" do
      it "returns person that is in the aspect" do
        aspect = FactoryGirl.create(:aspect)
        contact = FactoryGirl.create(:contact, user: aspect.user)
        aspect.contacts << contact
        expect(Person.in_aspects([aspect.id])).to include(contact.person)
      end

      it "returns same person in multiple aspects only once" do
        user = bob
        contact = FactoryGirl.create(:contact, user: user)
        ids = Array.new(2) do
          aspect = FactoryGirl.create(:aspect, user: user, name: r_str)
          aspect.contacts << contact
          aspect.id
        end

        expect(Person.in_aspects(ids)).to eq([contact.person])
      end
    end
  end

  describe "delegating" do
    it "delegates last_name to the profile" do
      expect(@person.last_name).to eq(@person.profile.last_name)
      @person.profile.update_attributes(:last_name => "Heathers")
      expect(@person.reload.last_name).to eq("Heathers")
    end
  end

  describe "valid url" do
    context "https urls" do
      let(:person) { FactoryGirl.build(:person, pod: Pod.find_or_create_by(url: "https://example.com")) }

      it "should add trailing slash" do
        expect(person.url).to eq("https://example.com/")
      end

      it "should return the receive url" do
        expect(person.receive_url).to eq("https://example.com/receive/users/#{person.guid}")
      end

      it "should return the atom url" do
        expect(person.atom_url).to eq("https://example.com/public/#{person.username}.atom")
      end

      it "should return the profile url" do
        expect(person.profile_url).to eq("https://example.com/u/#{person.username}")
      end
    end

    context "messed up urls" do
      let(:person) {
        FactoryGirl.build(:person, pod: Pod.find_or_create_by(url: "https://example.com/a/bit/messed/up"))
      }

      it "should return the correct url" do
        expect(person.url).to eq("https://example.com/")
      end

      it "should return the correct receive url" do
        expect(person.receive_url).to eq("https://example.com/receive/users/#{person.guid}")
      end

      it "should return the correct atom url" do
        expect(person.atom_url).to eq("https://example.com/public/#{person.username}.atom")
      end

      it "should return the correct profile url" do
        expect(person.profile_url).to eq("https://example.com/u/#{person.username}")
      end
    end

    it "should allow ports in the url" do
      person = FactoryGirl.build(:person, pod: Pod.find_or_create_by(url: "https://example.com:3000/"))
      expect(person.url).to eq("https://example.com:3000/")
    end

    it "should remove https port in the url" do
      person = FactoryGirl.build(:person, pod: Pod.find_or_create_by(url: "https://example.com:443/"))
      expect(person.url).to eq("https://example.com/")
    end
  end

  describe '#diaspora_handle' do
    context 'local people' do
      it 'uses the pod config url to set the diaspora_handle' do
        new_person = User.build(:username => "foo123", :email => "foo123@example.com", :password => "password", :password_confirmation => "password").person
        expect(new_person.diaspora_handle).to eq("foo123#{User.diaspora_id_host}")
      end

      it 'does not include www if it is set in app config' do
        allow(AppConfig).to receive(:pod_uri).and_return(Addressable::URI.parse('https://www.foobar.com/'))
        new_person = User.build(:username => "foo123", :email => "foo123@example.com", :password => "password", :password_confirmation => "password").person
        expect(new_person.diaspora_handle).to eq("foo123@foobar.com")
      end
    end

    context 'remote people' do
      it 'stores the diaspora_handle in the database' do
        expect(@person.diaspora_handle.include?(AppConfig.pod_uri.host)).to be false
      end
    end

    describe 'validation' do
      it 'is unique' do
        person_two = FactoryGirl.build(:person, :diaspora_handle => @person.diaspora_handle)
        expect(person_two).not_to be_valid
      end

      it 'is case insensitive' do
        person_two = FactoryGirl.build(:person, :diaspora_handle => @person.diaspora_handle.upcase)
        expect(person_two).not_to be_valid
      end
    end
  end

  context '.name_from_attrs' do
    before do
      @person = alice.person
      @profile = @person.profile
    end

    context 'with only first name' do
      it 'should return their first name for name' do
        expect(Person.name_from_attrs(@profile.first_name, nil, @profile.diaspora_handle)).to eq(@profile.first_name.strip)
      end
    end

    context 'with only last name' do
      it 'should return their last name for name' do
        expect(Person.name_from_attrs(nil, @profile.last_name, @profile.diaspora_handle)).to eq(@profile.last_name.strip)
      end
    end

    context 'with both first and last name' do
      it 'should return their composed name for name' do
        expect(Person.name_from_attrs(@profile.first_name, @profile.last_name, @profile.diaspora_handle)).to eq("#{@profile.first_name.strip} #{@profile.last_name.strip}")
      end
    end

    context 'without first nor last name' do
      it 'should display their diaspora handle' do
        expect(Person.name_from_attrs(nil, nil, @profile.diaspora_handle)).to eq(@profile.diaspora_handle)
      end
    end
  end

  describe '#name' do
    it 'calls Person.name_from_attrs' do
      profile = alice.person.profile
      expect(Person).to receive(:name_from_attrs).with(profile.first_name, profile.last_name, profile.person.diaspora_handle)
      alice.name
    end

    it "strips endline whitespace" do
      profile = alice.person.profile
      profile.first_name = "maxwell "
      profile.last_name = "salzberg "
      expect(alice.name).to eq("maxwell salzberg")
    end
  end

  it '#owns? posts' do
    person_message = FactoryGirl.create(:status_message, :author => @person)
    person_two = FactoryGirl.create(:person)

    expect(@person.owns?(person_message)).to be true
    expect(person_two.owns?(person_message)).to be false
  end

  describe "disconnecting" do
    before do
      @user2 = FactoryGirl.create(:user)
      @aspect = @user.aspects.create(:name => "Dudes")
      @aspect2 = @user2.aspects.create(:name => "Abscence of Babes")
    end
    it 'should not delete an orphaned contact' do
      @user.contacts.create(:person => @person, :aspects => [@aspect])

      expect { @user.disconnect(@user.contact_for(@person)) }.not_to change(Person, :count)
    end

    it 'should not delete an un-orphaned contact' do
      @user.contacts.create(:person => @person, :aspects => [@aspect])
      @user2.contacts.create(:person => @person, :aspects => [@aspect2])

      expect { @user.disconnect(@user.contact_for(@person)) }.not_to change(Person, :count)
    end
  end

  describe "#first_name" do
    it 'returns username if first_name is not present in profile' do
      alice.person.profile.update_attributes(:first_name => "")
      expect(alice.person.first_name).to eq(alice.username)
    end

    it 'returns first words in first_name if first_name is present' do
      alice.person.profile.update_attributes(:first_name => "First Mid Last")
      expect(alice.person.first_name).to eq("First Mid")
    end

    it 'returns first word in first_name if first_name is present' do
      alice.person.profile.update_attributes(:first_name => "Alice")
      expect(alice.person.first_name).to eq("Alice")
    end
  end

  describe '.search' do
    before do
      Person.delete_all
      @user = FactoryGirl.create(:user_with_aspect)
      user_profile = @user.person.profile
      user_profile.first_name = "aiofj"
      user_profile.last_name = "asdji"
      user_profile.save

      @robert_grimm = FactoryGirl.build(:person)
      @eugene_weinstein = FactoryGirl.build(:person)
      @yevgeniy_dodis = FactoryGirl.build(:person)
      @casey_grippi = FactoryGirl.build(:person)
      @invisible_person = FactoryGirl.build(:person)
      @closed_account = FactoryGirl.build(:person, closed_account: true)

      @robert_grimm.profile.first_name = "Robert"
      @robert_grimm.profile.last_name = "Grimm"
      @robert_grimm.profile.save
      @robert_grimm.reload

      @eugene_weinstein.profile.first_name = "Eugene"
      @eugene_weinstein.profile.last_name = "Weinstein"
      @eugene_weinstein.profile.save
      @eugene_weinstein.reload

      @yevgeniy_dodis.profile.first_name = "Yevgeniy"
      @yevgeniy_dodis.profile.last_name = "Dodis"
      @yevgeniy_dodis.profile.save
      @yevgeniy_dodis.reload

      @casey_grippi.profile.first_name = "Casey"
      @casey_grippi.profile.last_name = "Grippi"
      @casey_grippi.profile.save
      @casey_grippi.reload

      @invisible_person.profile.first_name = "Johnson"
      @invisible_person.profile.last_name = "Invisible"
      @invisible_person.profile.searchable = false
      @invisible_person.profile.save
      @invisible_person.reload

      @closed_account.profile.first_name = "Closed"
      @closed_account.profile.last_name = "Account"
      @closed_account.profile.save
      @closed_account.reload
    end

    it 'orders results by last name' do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save!

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save!

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save!

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save!

      people = Person.search("AAA", @user)
      expect(people.map { |p| p.name }).to eq([@yevgeniy_dodis, @robert_grimm, @casey_grippi, @eugene_weinstein].map { |p| p.name })
    end

    it 'returns nothing on an empty query' do
      people = Person.search("", @user)
      expect(people).to be_empty
    end

    it 'returns nothing on a one-character query' do
      people = Person.search("i", @user)
      expect(people).to be_empty
    end

    it 'returns results for partial names' do
      people = Person.search("Eug", @user)
      expect(people.count).to eq(1)
      expect(people.first).to eq(@eugene_weinstein)

      people = Person.search("wEi", @user)
      expect(people.count).to eq(1)
      expect(people.first).to eq(@eugene_weinstein)

      people = Person.search("gri", @user)
      expect(people.count).to eq(2)
      expect(people.first).to eq(@robert_grimm)
      expect(people.second).to eq(@casey_grippi)
    end

    it 'returns results for full names' do
      people = Person.search("Casey Grippi", @user)
      expect(people.count).to eq(1)
      expect(people.first).to eq(@casey_grippi)
    end

    it "doesn't display people that are neither searchable nor contacts" do
      expect(Person.search("Johnson", @user)).to be_empty
    end

    it "doesn't display closed accounts" do
      expect(Person.search("Closed", @user)).to be_empty
      expect(Person.search("Account", @user)).to be_empty
      expect(Person.search(@closed_account.diaspora_handle, @user)).to be_empty
    end

    it "displays contacts that are not searchable" do
      @user.contacts.create(person: @invisible_person, aspects: [@user.aspects.first])
      people = Person.search("Johnson", @user)
      expect(people.count).to eq(1)
      expect(people.first).to eq(@invisible_person)
    end

    it 'returns results for Diaspora handles' do
      people = Person.search(@robert_grimm.diaspora_handle, @user)
      expect(people).to eq([@robert_grimm])
    end

    it "puts the searching user's contacts first" do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save!

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save!

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save!

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save!

      @user.contacts.create(:person => @casey_grippi, :aspects => [@user.aspects.first])

      people = Person.search("AAA", @user)
      expect(people.map { |p| p.name }).to eq([@casey_grippi, @yevgeniy_dodis, @robert_grimm, @eugene_weinstein].map { |p| p.name })
    end

    context "only contacts" do
      before do
        @robert_contact = @user.contacts.create(person: @robert_grimm, aspects: [@user.aspects.first])
        @eugene_contact = @user.contacts.create(person: @eugene_weinstein, aspects: [@user.aspects.first])
        @invisible_contact = @user.contacts.create(person: @invisible_person, aspects: [@user.aspects.first])
      end

      it "orders results by last name" do
        @robert_grimm.profile.first_name = "AAA"
        @robert_grimm.profile.save!

        @eugene_weinstein.profile.first_name = "AAA"
        @eugene_weinstein.profile.save!

        @casey_grippi.profile.first_name = "AAA"
        @casey_grippi.profile.save!

        people = Person.search("AAA", @user, only_contacts: true)
        expect(people.map(&:name)).to eq([@robert_grimm, @eugene_weinstein].map(&:name))
      end

      it "returns nothing on an empty query" do
        people = Person.search("", @user, only_contacts: true)
        expect(people).to be_empty
      end

      it "returns nothing on a one-character query" do
        people = Person.search("i", @user, only_contacts: true)
        expect(people).to be_empty
      end

      it "returns results for partial names" do
        people = Person.search("Eug", @user, only_contacts: true)
        expect(people.count).to eq(1)
        expect(people.first).to eq(@eugene_weinstein)

        people = Person.search("wEi", @user, only_contacts: true)
        expect(people.count).to eq(1)
        expect(people.first).to eq(@eugene_weinstein)

        @user.contacts.create(person: @casey_grippi, aspects: [@user.aspects.first])
        people = Person.search("gri", @user, only_contacts: true)
        expect(people.count).to eq(2)
        expect(people.first).to eq(@robert_grimm)
        expect(people.second).to eq(@casey_grippi)
      end

      it "returns results for full names" do
        people = Person.search("Robert Grimm", @user, only_contacts: true)
        expect(people.count).to eq(1)
        expect(people.first).to eq(@robert_grimm)
      end

      it "returns results for Diaspora handles" do
        people = Person.search(@robert_grimm.diaspora_handle, @user, only_contacts: true)
        expect(people).to eq([@robert_grimm])
      end
    end
  end

  describe "#public_key" do
    it "returns the public key for the person" do
      key = @person.public_key
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(@person.serialized_public_key)
    end

    it "handles broken keys and returns nil" do
      @person.update_attributes(serialized_public_key: "broken")
      expect(@person.public_key).to be_nil
    end
  end

  context 'people finders for webfinger' do
    let(:user) { FactoryGirl.create(:user) }
    let(:person) { FactoryGirl.create(:person) }

    describe '.by_account_identifier' do
      it 'should find a local users person' do
        p = Person.by_account_identifier(user.diaspora_handle)
        expect(p).to eq(user.person)
      end

      it 'should find remote users person' do
        p = Person.by_account_identifier(person.diaspora_handle)
        expect(p).to eq(person)
      end

      it 'should downcase and strip the diaspora_handle' do
        dh_upper = "    " + user.diaspora_handle.upcase + "   "
        expect(Person.by_account_identifier(dh_upper)).to eq(user.person)
      end

      it "finds a local person with a mixed-case username" do
        user = FactoryGirl.create(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user.person.diaspora_handle)
        expect(person).to eq(user.person)
      end

      it "is case insensitive" do
        user1 = FactoryGirl.create(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user1.person.diaspora_handle.upcase)
        expect(person).to eq(user1.person)
      end

      it "should only find people who are exact matches (1/2)" do
        FactoryGirl.create(:person, diaspora_handle: "tomtom@tom.joindiaspora.com")
        FactoryGirl.create(:person, diaspora_handle: "tom@tom.joindiaspora.com")
        expect(Person.by_account_identifier("tom@tom.joindiaspora.com").diaspora_handle)
          .to eq("tom@tom.joindiaspora.com")
      end

      it "should only find people who are exact matches (2/2)" do
        FactoryGirl.create(:person, diaspora_handle: "tomtom@tom.joindiaspora.com")
        FactoryGirl.create(:person, diaspora_handle: "tom@tom.joindiaspora.comm")
        expect(Person.by_account_identifier("tom@tom.joindiaspora.com")).to be_nil
      end
    end
  end

  describe '#has_photos?' do
    it 'returns false if the user has no photos' do
      expect(alice.person.has_photos?).to be false
    end

    it 'returns true if the user has photos' do
      alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id)

      expect(alice.person.has_photos?).to be true
    end
  end

  describe '#as_json' do
    it 'returns a hash representation of a person' do
      expect(@person.as_json).to eq(
        id:     @person.id,
        guid:   @person.guid,
        name:   @person.name,
        avatar: @person.profile.image_url(size: :thumb_medium),
        handle: @person.diaspora_handle,
        url:    Rails.application.routes.url_helpers.person_path(@person)
      )
    end
    it 'return tags if asked' do
      expect(@person.as_json(:includes => "tags")).
        to eq(@person.as_json.merge(:tags => @person.profile.tags.map { |t| "##{t.name}" }))
    end
  end

  describe '.community_spotlight' do
    describe "when the pod owner hasn't set up any community spotlight members" do
      it 'returns people with the community spotlight role' do
        Role.add_spotlight(bob.person)
        expect(Person.community_spotlight).to be_present
      end

      it "returns an empty array" do
        expect(Person.community_spotlight).to eq([])
      end
    end
  end

  describe '#lock_access!' do
    it 'sets the closed_account flag' do
      @person.lock_access!
      expect(@person.reload.closed_account).to be true
    end
  end

  describe "#clear_profile!!" do
    before do
      @person = FactoryGirl.build(:person)
    end

    it 'calls Profile#tombstone!' do
      expect(@person.profile).to receive(:tombstone!)
      @person.clear_profile!
    end
  end

  context "validation" do
    it "validates that no other person with same guid exists" do
      person = FactoryGirl.build(:person)
      person.guid = alice.guid

      expect(person.valid?).to be_falsey
      expect(person.errors.full_messages).to include("Person with same GUID already exists: #{alice.diaspora_handle}")
    end
  end
end
