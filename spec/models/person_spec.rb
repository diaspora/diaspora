#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Person do
  before do
    @user = make_user
    @user2 = make_user
    @person = Factory.create(:person)
    @aspect = @user.aspects.create(:name => "Dudes")
    @aspect2 = @user2.aspects.create(:name => "Abscence of Babes")
  end

  describe "delegating" do
    it "delegates last_name to the profile" do
      @person.last_name.should == @person.profile.last_name
      @person.profile.update_attributes(:last_name => "Heathers")
      @person.reload.last_name.should == "Heathers"
    end
  end

  describe "vaild url" do
      it 'should allow for https urls' do
      person = Factory.create(:person, :url => "https://example.com")
      person.should be_valid
      end
    end


  describe '#diaspora_handle' do
    context 'local people' do
      it 'uses the pod config url to set the diaspora_handle' do
        new_user = Factory.create(:user)
        new_user.person.diaspora_handle.should == new_user.username + "@" + AppConfig[:pod_uri].host
      end
    end

    context 'remote people' do
      it 'stores the diaspora_handle in the database' do
        @person.diaspora_handle.include?(AppConfig[:pod_uri].host).should be false
      end
    end

    describe 'validation' do
      it 'is unique' do
        person_two = Factory.build(:person, :diaspora_handle => @person.diaspora_handle)
        person_two.should_not be_valid
      end

      it 'is case insensitive' do
        person_two = Factory.build(:person, :diaspora_handle => @person.diaspora_handle.upcase)
        person_two.should_not be_valid
      end
    end
  end

  context '#name' do
    let!(:user) { make_user }
    let!(:person) { user.person }
    let!(:profile) { person.profile }

    context 'with first name' do
      it 'should return their name for name' do
        person.name.should match /#{profile.first_name}|#{profile.last_name}/
      end
    end

    context 'without first name' do
      it 'should display their diaspora handle' do
        person.profile.first_name = nil
        person.profile.last_name = nil
        person.save!
        person.name.should == person.diaspora_handle
      end
    end
  end

  describe 'xml' do
    before do
      @xml = @person.to_xml.to_s
    end

    it 'should serialize to xml' do
      @xml.include?("person").should == true
    end

    it 'should have a profile in its xml' do
      @xml.include?("first_name").should == true

    end
  end

  it '#owns? posts' do
    person_message = Factory.create(:status_message, :person => @person)
    person_two =     Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  it "deletes all of a person's posts upon person deletion" do
    person = Factory.create(:person)

    status = Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => @person)

    lambda {person.destroy}.should change(Post, :count).by(-1)
  end

  it "does not delete a person's comments on person deletion" do
    person = Factory.create(:person)

    status_message = Factory.create(:status_message, :person => @person)

    Factory.create(:comment, :person_id => person.id, :diaspora_handle => person.diaspora_handle, :text => "i love you",     :post => status_message)
    Factory.create(:comment, :person_id => @person.id,:diaspora_handle => @person.diaspora_handle,  :text => "you are creepy", :post => status_message)

    lambda {person.destroy}.should_not change(Comment, :count)
  end

  describe "disconnecting" do
    it 'should not delete an orphaned contact' do
      @user.activate_contact(@person, @aspect)

      lambda {@user.disconnect(@person)}.should_not change(Person, :count)
    end

    it 'should not delete an un-orphaned contact' do
      @user.activate_contact(@person, @aspect)
      @user2.activate_contact(@person, @aspect2)

      lambda {@user.disconnect(@person)}.should_not change(Person, :count)
    end
  end

  describe '.search' do
    before do
      @connected_person_one   = Factory.create(:person)
      @connected_person_two   = Factory.create(:person)
      @connected_person_three = Factory.create(:person)
      @connected_person_four  = Factory.create(:person)

      @connected_person_one.profile.first_name = "Robert"
      @connected_person_one.profile.last_name  = "Grimm"
      @connected_person_one.profile.save

      @connected_person_two.profile.first_name = "Eugene"
      @connected_person_two.profile.last_name  = "Weinstein"
      @connected_person_two.save

      @connected_person_three.profile.first_name = "Yevgeniy"
      @connected_person_three.profile.last_name  = "Dodis"
      @connected_person_three.save

      @connected_person_four.profile.first_name = "Casey"
      @connected_person_four.profile.last_name  = "Grippi"
      @connected_person_four.save
    end

    it 'should return nothing on an emprty query' do
      people = Person.search("")
      people.empty?.should be true
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eu")
      people.include?(@connected_person_two).should   == true
      people.include?(@connected_person_one).should   == false
      people.include?(@connected_person_three).should == false
      people.include?(@connected_person_four).should  == false

      people = Person.search("wEi")
      people.include?(@connected_person_two).should   == true
      people.include?(@connected_person_one).should   == false
      people.include?(@connected_person_three).should == false
      people.include?(@connected_person_four).should  == false

      people = Person.search("gri")
      people.include?(@connected_person_one).should   == true
      people.include?(@connected_person_four).should  == true
      people.include?(@connected_person_two).should   == false
      people.include?(@connected_person_three).should == false
    end

    it 'should yield results on full names' do
      people = Person.search("Casey Grippi")
      people.should == [@connected_person_four]
    end

    it 'should only display searchable people' do
      invisible_person = Factory(:person, :profile => {:searchable => false, :first_name => "johnson"})
      Person.search("johnson").should_not include invisible_person
      Person.search("").should_not include invisible_person
    end

    it 'should search on handles' do
      Person.search(@connected_person_one.diaspora_handle).should include @connected_person_one
    end
  end

  context 'people finders for webfinger' do
    let(:user) {make_user}
    let(:person) {Factory(:person)}

    describe '.by_account_identifier' do
      it 'should find a local users person' do
        p = Person.by_account_identifier(user.diaspora_handle)
        p.should == user.person
      end

      it 'should find remote users person' do
        p = Person.by_account_identifier(person.diaspora_handle)
        p.should == person
      end

      it 'should downcase and strip the diaspora_handle' do
        dh_upper = "    " + user.diaspora_handle.upcase + "   "
        Person.by_account_identifier(dh_upper).should == user.person
      end

      it "finds a local person with a mixed-case username" do
        user = Factory(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user.person.diaspora_handle)
        person.should == user.person
      end

      it "is case insensitive" do
        user1 = Factory(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user1.person.diaspora_handle.upcase)
        person.should == user1.person
      end

      it 'should only find people who are exact matches (1/2)' do
        user = Factory(:user, :username => "SaMaNtHa")
        person = Factory(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        user.person.diaspora_handle = "tom@tom.joindiaspora.com"
        user.person.save
        Person.by_account_identifier("tom@tom.joindiaspora.com").diaspora_handle.should == "tom@tom.joindiaspora.com"
      end

      it 'should only find people who are exact matches (2/2)' do
        person = Factory(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        person1 = Factory(:person, :diaspora_handle => "tom@tom.joindiaspora.comm")
        f = Person.by_account_identifier("tom@tom.joindiaspora.com")
        f.should be nil
      end


    end

    describe '.local_by_account_identifier' do
      it 'should find local users people' do
        p = Person.local_by_account_identifier(user.diaspora_handle)
        p.should == user.person
      end

      it 'should not find a remote person' do
        p = Person.local_by_account_identifier(@person.diaspora_handle)
        p.should be nil
      end

      it 'should call .by_account_identifier' do
        Person.should_receive(:by_account_identifier)
        Person.local_by_account_identifier(@person.diaspora_handle)
      end
    end
  end
end
