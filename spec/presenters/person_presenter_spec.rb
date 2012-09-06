require "spec_helper"

describe PersonPresenter do
  let(:profile_user) { FactoryGirl.create(:user_with_aspect) }
  let(:person) { profile_user.person }

  describe "#as_json" do
    context "with no current_user" do
      it "returns the user's public information if a user is not logged in" do
        PersonPresenter.new(person, nil).as_json.should include(person.as_api_response(:backbone))
      end
    end

    context "with a current_user" do
      let(:current_user) { FactoryGirl.create(:user)}
      let(:presenter){ PersonPresenter.new(person, current_user) }

      it "doesn't share private information when the users aren't connected" do
        presenter.as_json.should_not have_key(:location)
      end

      it "has private information when the person is sharing with the current user" do
        person.should_receive(:shares_with).with(current_user).and_return(true)
        presenter.as_json.should have_key(:location)
      end

      it "returns the user's private information if a user is logged in as herself" do
        PersonPresenter.new(current_user.person, current_user).as_json.should have_key(:location)
      end
    end
  end
end