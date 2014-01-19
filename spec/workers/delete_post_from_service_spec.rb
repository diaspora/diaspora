require 'spec_helper'

describe Workers::DeletePostFromService do
  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id, :public =>true, :facebook_id => "23456" )
  end

  it 'calls service#delete_post with given service' do
    m = double()
    url = "foobar"
    m.should_receive(:delete_post)
    Service.stub(:find_by_id).and_return(m)
    Workers::DeletePostFromService.new.perform("123", @post.id.to_s)
  end
end
