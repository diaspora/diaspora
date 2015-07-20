require "spec_helper"

describe Role do
  let(:person) { create(:person) }

  describe "validations" do
    it { should validate_presence_of(:person) }
    it { should validate_uniqueness_of(:name).scoped_to(:person_id) }
    it { should validate_inclusion_of(:name).in_array(%w(admin spotlight)) }
  end

  describe "associations" do
    it { should belong_to(:person) }
  end

  describe "scopes" do
    let!(:admin_role) { person.roles.create(name: "admin") }
    let!(:spotlight_role) { person.roles.create(name: "spotlight") }

    describe ".admins" do
      it "includes admin roles" do
        expect(Role.admins).to match_array([admin_role])
      end
    end
  end

  describe ".is_admin?" do
    it "defaults to false" do
      expect(Role.is_admin?(person)).to be false
    end

    context "when the person is an admin" do
      before { person.roles.create(name: "admin") }

      it "is true" do
        expect(Role.is_admin?(person)).to be true
      end
    end
  end

  describe ".add_admin" do
    it "creates the admin role" do
      Role.add_admin(person)
      expect(person.roles.where(name: "admin")).to exist
    end
  end

  describe ".add_spotlight" do
    it "creates the spotlight role" do
      Role.add_spotlight(person)
      expect(person.roles.where(name: "spotlight")).to exist
    end
  end
end
