require 'spec_helper'

describe Job::PostToServices do
  it 'calls post to services from the given user with given post' do
    user = alice
    aspect = user.aspects.create(:name => "yeah")
    post = user.post(:status_message, :message => 'foo', :to => aspect.id)
    User.stub!(:find_by_id).with(user.id.to_s).and_return(user)
    m = mock()
    url = "foobar"
    m.should_receive(:post).with(anything, url)
    user.stub!(:services).and_return([m])
    Job::PostToServices.perform(user.id.to_s, post.id.to_s, url)
  end
end
