require 'spec_helper'

describe Block do
  describe 'validations' do
    it 'doesnt allow you to block yourself' do
      block = alice.blocks.create(:person => alice.person)
      block.errors[:person_id].size.should == 1
    end
  end
end