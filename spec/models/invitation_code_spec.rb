require 'spec_helper'

describe InvitationCode do
  it 'has a valid factory' do
    Factory(:invitation_code).should be_valid
  end
end
