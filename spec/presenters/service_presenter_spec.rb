require 'spec_helper'

describe ServicePresenter do
  describe '#as_json' do
    it 'includes the provider name of the json' do
      presenter = ServicePresenter.new(stub(:provider => "fakebook"))
      presenter.as_json[:provider].should == 'fakebook'
    end
  end
end