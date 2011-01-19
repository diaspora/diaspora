require 'spec_helper'

describe Job::PostToService do
  it 'calls service#post with the given service' do
    user = alice
    aspect = user.aspects.create(:name => "yeah")
    post = user.post(:status_message, :message => 'foo', :to => aspect.id)
    User.stub!(:find_by_id).with(user.id.to_s).and_return(user)
    m = mock()
    url = "foobar"
    m.should_receive(:post).with(anything, url)
    Service.stub!(:find_by_id).and_return(m)
    Job::PostToService.perform("123", post.id.to_s, url)
  end
end
