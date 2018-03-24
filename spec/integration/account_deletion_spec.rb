# frozen_string_literal: true

describe "deleteing account", type: :request do
  def account_removal_method
    AccountDeleter.new(person).perform!
    subject.reload
  end

  context "of local user" do
    subject(:user) { FactoryGirl.create(:user_with_aspect) }
    let(:person) { user.person }

    before do
      DataGenerator.create(subject, :generic_user_data)
    end

    it_behaves_like "deletes all of the user data"

    it_behaves_like "it removes the person associations"

    it_behaves_like "it keeps the person conversations"
  end

  context "of remote person" do
    subject(:person) { remote_raphael }

    before do
      DataGenerator.create(subject, :generic_person_data)
    end

    it_behaves_like "it removes the person associations"

    it_behaves_like "it keeps the person conversations"

    it_behaves_like "it makes account closed and clears profile" do
      before do
        account_removal_method
      end
    end
  end
end
