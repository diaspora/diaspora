require 'spec_helper'

describe Jobs::PostToServices do
  it 'calls post to services from the given user with given post' do
    user = make_user
    aspect = user.aspects.create(:name => "yeah")
    post = user.post(:status_message, :message => 'foo', :to => aspect.id)
    User.stub!(:find_by_id).with(user.id.to_s).and_return(user)
    user.stub!(:services).and_return([])
    user.should_receive(:post_to_services)
    url = "foobar"
    Jobs::PostToServices.perform(user.id.to_s, post.id.to_s, url)
  end
end
