# frozen_string_literal: true

describe Role do
  let!(:person) { create(:person) }
  let!(:admin) { create(:person) }
  let!(:admin_role) { admin.roles.create(name: "admin") }
  let!(:moderator) { create(:person) }
  let!(:moderator_role) { moderator.roles.create(name: "moderator") }

  describe "validations" do
    it "validates the presence of the person" do
      role = Role.new(name: "admin")
      role.valid?
      expect(role.errors.full_messages).to include "Person must exist"
    end

    it { should validate_uniqueness_of(:name).scoped_to(:person_id) }
    it { should validate_inclusion_of(:name).in_array(%w(admin spotlight moderator)) }
  end

  describe "associations" do
    it { should belong_to(:person) }
  end

  describe "scopes" do
    describe ".admins" do
      it "includes admin roles" do
        expect(Role.admins).to match_array([admin_role])
      end
    end

    describe ".moderators" do
      it "should include admins" do
        expect(Role.moderators).to include(admin_role)
      end

      it "should include moderators" do
        expect(Role.moderators).to include(moderator_role)
      end
    end
  end

  describe ".is_admin?" do
    it "defaults to false" do
      expect(Role.is_admin?(person)).to be false
    end

    context "when the person is an admin" do
      it "is true" do
        expect(Role.is_admin?(admin)).to be true
      end
    end

    context "when the person is a moderator" do
      it "is false" do
        expect(Role.is_admin?(moderator)).to be false
      end
    end
  end

  describe ".moderator?" do
    it "defaults to false" do
      expect(Role.moderator?(person)).to be false
    end

    context "when the person is a moderator" do
      it "is true" do
        expect(Role.moderator?(moderator)).to be true
      end
    end

    context "when the person is an admin" do
      it "is true" do
        expect(Role.moderator?(admin)).to be true
      end
    end
  end

  describe ".add_admin" do
    it "creates the admin role" do
      Role.add_admin(person)
      expect(person.roles.where(name: "admin")).to exist
    end
  end

  describe ".add_moderator" do
    it "creates the moderator role" do
      Role.add_moderator(person)
      expect(person.roles.where(name: "moderator")).to exist
    end
  end

  describe ".add_spotlight" do
    it "creates the spotlight role" do
      Role.add_spotlight(person)
      expect(person.roles.where(name: "spotlight")).to exist
    end
  end
end
