require 'spec_helper'

describe Block do
  describe 'validations' do
    it 'doesnt allow you to block yourself' do
      block = alice.blocks.create(:person => alice.person)

      block.should have(1).error_on(:person_id)
    end
  end
end