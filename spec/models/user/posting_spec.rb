require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @group = @user.group(:name => 'heroes')
   end
  it 'should not be able to post without a group' do
    proc {@user.post(:status_message, :message => "heyheyhey")}.should raise_error /You must post to someone/ 
  end
end
