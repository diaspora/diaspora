require "spec_helper"

describe PersonPresenter do
  let(:profile_user) { FactoryGirl.create(:user_with_aspect) }
  let(:person) { profile_user.person }

  describe "#as_json" do
    context "with no current_user" do
      it "returns the user's public information if a user is not logged in" do
        expect(PersonPresenter.new(person, nil).as_json).to include(person.as_api_response(:backbone).except(:avatar))
      end
    end

    context "with a current_user" do
      let(:current_user) { FactoryGirl.create(:user)}
      let(:presenter){ PersonPresenter.new(person, current_user) }

      it "doesn't share private information when the users aren't connected" do
        expect(presenter.as_json).not_to have_key(:location)
      end

      it "has private information when the person is sharing with the current user" do
        expect(person).to receive(:shares_with).with(current_user).and_return(true)
        expect(presenter.as_json).to have_key(:location)
      end

      it "returns the user's private information if a user is logged in as herself" do
        expect(PersonPresenter.new(current_user.person, current_user).as_json).to have_key(:location)
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
