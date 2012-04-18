require 'spec_helper'
describe OEmbedPresenter do
  it 'works' do
    OEmbedPresenter.new(Factory(:status_message)).to_json.should_not be_nil
  end
end