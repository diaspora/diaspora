# frozen_string_literal: true

describe PersonPresenter do
  let(:profile_user) { FactoryGirl.create(:user_with_aspect) }
  let(:person) { profile_user.person }

  let(:mutual_contact) {
    FactoryGirl.create(:contact, user: current_user, person: person, sharing: true, receiving: true)
  }
  let(:receiving_contact) {
    FactoryGirl.create(:contact, user: current_user, person: person, sharing: false, receiving: true)
  }
  let(:sharing_contact) {
    FactoryGirl.create(:contact, user: current_user, person: person, sharing: true, receiving: false)
  }
  let(:non_contact) {
    FactoryGirl.create(:contact, user: current_user, person: person, sharing: false, receiving: false)
  }

  describe "#as_json" do
    context "with no current_user" do
      it "returns the user's basic profile" do
        expect(PersonPresenter.new(person, nil).as_json).to include(person.as_api_response(:backbone).except(:avatar))
      end

      it "returns the user's additional profile if the user has set additional profile public" do
        person.profile.public_details = true
        expect(PersonPresenter.new(person, nil).as_json[:profile]).to include(*%i(location bio gender birthday))
      end

      it "doesn't return user's additional profile if the user hasn't set additional profile public" do
        person.profile.public_details = false
        expect(PersonPresenter.new(person, nil).as_json[:profile]).not_to include(*%i(location bio gender birthday))
      end
    end

    context "with a current_user" do
      let(:current_user) { FactoryGirl.create(:user) }
      let(:presenter){ PersonPresenter.new(person, current_user) }
      # here private information == addtional user profile, because additional profile by default is private

      it "doesn't share private information when the users aren't connected" do
        allow(current_user).to receive(:contact_for) { non_contact }
        expect(person.profile.public_details).to be_falsey
        expect(presenter.as_json[:show_profile_info]).to be_falsey
        expect(presenter.as_json[:profile]).not_to have_key(:location)
      end

      it "doesn't share private information when the current user is sharing with the person" do
        allow(current_user).to receive(:contact_for) { receiving_contact }
        expect(person.profile.public_details).to be_falsey
        expect(presenter.as_json[:show_profile_info]).to be_falsey
        expect(presenter.as_json[:profile]).not_to have_key(:location)
      end

      it "shares private information when the users aren't connected, but profile is public" do
        allow(current_user).to receive(:contact_for) { non_contact }
        person.profile.public_details = true
        expect(presenter.as_json[:show_profile_info]).to be_truthy
        expect(presenter.as_json[:relationship]).to be(:not_sharing)
        expect(presenter.as_json[:profile]).to have_key(:location)
      end

      it "has private information when the person is sharing with the current user" do
        allow(current_user).to receive(:contact_for) { sharing_contact }
        expect(person.profile.public_details).to be_falsey
        pr_json = presenter.as_json
        expect(pr_json[:show_profile_info]).to be_truthy
        expect(pr_json[:profile]).to have_key(:location)
      end

      it "has private information when the relationship is mutual" do
        allow(current_user).to receive(:contact_for) { mutual_contact }
        expect(person.profile.public_details).to be_falsey
        pr_json = presenter.as_json
        expect(pr_json[:show_profile_info]).to be_truthy
        expect(pr_json[:profile]).to have_key(:location)
      end

      it "returns the user's private information if a user is logged in as herself" do
        current_person_presenter = PersonPresenter.new(current_user.person, current_user)
        expect(current_user.person.profile.public_details).to be_falsey
        expect(current_person_presenter.as_json[:show_profile_info]).to be_truthy
        expect(current_person_presenter.as_json[:profile]).to have_key(:location)
      end
    end
  end

  describe "#full_hash" do
    let(:current_user) { FactoryGirl.create(:user) }

    before do
      @p = PersonPresenter.new(person, current_user)
    end

    context "relationship" do
      it "is mutual?" do
        allow(current_user).to receive(:contact_for) { mutual_contact }
        expect(@p.full_hash[:relationship]).to be(:mutual)
      end

      it "is receiving?" do
        allow(current_user).to receive(:contact_for) { receiving_contact }
        expect(@p.full_hash[:relationship]).to be(:receiving)
      end

      it "is sharing?" do
        allow(current_user).to receive(:contact_for) { sharing_contact }
        expect(@p.full_hash[:relationship]).to be(:sharing)
      end

      it "isn't sharing?" do
        allow(current_user).to receive(:contact_for) { non_contact }
        expect(@p.full_hash[:relationship]).to be(:not_sharing)
      end
    end

    describe "block" do
      it "contains the block id if it exists" do
        allow(current_user).to receive(:contact_for) { non_contact }
        allow(current_user).to receive(:block_for) { double(id: 1) }
        expect(@p.full_hash[:block][:id]).to be(1)
      end

      it "is false if no block is present" do
        allow(current_user).to receive(:contact_for) { non_contact }
        expect(@p.full_hash[:block]).to be(false)
      end
    end
  end

  describe "#hovercard" do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:presenter) { PersonPresenter.new(person, current_user) }

    it "contains data required for hovercard" do
      mutual_contact
      expect(presenter.hovercard).to have_key(:profile)
      expect(presenter.hovercard[:profile]).to have_key(:avatar)
      expect(presenter.hovercard[:profile]).to have_key(:tags)
      expect(presenter.hovercard).to have_key(:contact)
      expect(presenter.hovercard[:contact]).to have_key(:aspect_memberships)
    end
  end
end
