# frozen_string_literal: true

describe ServicePresenter do
  describe '#as_json' do
    it 'includes the provider name of the json' do
      presenter = ServicePresenter.new(double(:provider => "fakebook"))
      expect(presenter.as_json[:provider]).to eq('fakebook')
    end
  end
end