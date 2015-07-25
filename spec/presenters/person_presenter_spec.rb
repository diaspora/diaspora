require "spec_helper"

describe PersonPresenter do
  let(:profile_user) { FactoryGirl.create(:user_with_aspect) }
  let(:person) { profile_user.person }

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
      let(:current_user) { FactoryGirl.create(:user)}
      let(:presenter){ PersonPresenter.new(person, current_user) }
      # here private information == addtional user profile, because additional profile by default is private

      it "doesn't share private information when the users aren't connected" do
        expect(person.profile.public_details).to be_falsey
        expect(presenter.as_json[:show_profile_info]).to be_falsey
        expect(presenter.as_json[:profile]).not_to have_key(:location)
      end

      it "shares private information when the users aren't connected, but profile is public" do
        person.profile.public_details = true
        expect(presenter.as_json[:show_profile_info]).to be_truthy
        expect(presenter.as_json[:relationship]).to be(:not_sharing)
        expect(presenter.as_json[:profile]).to have_key(:location)
      end

      it "has private information when the person is sharing with the current user" do
        expect(person).to receive(:shares_with).with(current_user).and_return(true)
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
    let(:mutual_contact) { double(:id => 1, :mutual? => true,  :sharing? => true,  :receiving? => true ) }
    let(:receiving_contact) { double(:id => 1, :mutual? => false, :sharing? => false, :receiving? => true)  }
    let(:sharing_contact) { double(:id => 1, :mutual? => false, :sharing? => true,  :receiving? => false) }
    let(:non_contact) { double(:id => 1, :mutual? => false, :sharing? => false, :receiving? => false) }

    before do
      @p = PersonPresenter.new(person, current_user)
    end

    context "relationship" do
      it "is blocked?" do
        allow(current_user).to receive(:block_for) { double(id: 1) }
        allow(current_user).to receive(:contact_for) { non_contact }
        expect(@p.full_hash[:relationship]).to be(:blocked)
      end

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
  end
end
