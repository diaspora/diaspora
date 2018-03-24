# frozen_string_literal: true

describe AspectMembershipPresenter do
  before do
    @am = alice.aspects.where(:name => "generic").first.aspect_memberships.first
    @presenter = AspectMembershipPresenter.new(@am)
  end

  describe '#base_hash' do
    it 'works' do
      expect(@presenter.base_hash).to be_present
    end
  end

end
