require 'spec_helper'

describe OAuth2::Strategy::Base do
  it 'should initialize with a Client' do
    lambda{OAuth2::Strategy::Base.new(OAuth2::Client.new('abc', 'def'))}.should_not raise_error
  end
end
