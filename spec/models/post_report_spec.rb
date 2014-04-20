require 'spec_helper'

describe PostReport do
  it 'should validates presence of user' do
    subject.should have(1).error_on(:user)
  end
  it 'should validates presence of post' do
    subject.should have(1).error_on(:post)
  end
end
