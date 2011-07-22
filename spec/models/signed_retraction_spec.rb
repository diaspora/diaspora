require 'spec_helper'

describe SignedRetraction do
  before do
    @post = Factory(:status_message, :author => bob.person, :public => true)
    @resharer = Factory(:user)
    @post.reshares << Factory.create(:reshare,:root_id => @post.id, :author => @resharer.person)
    @post.save!
  end
  describe '#perform' do
    it "dispatches the retraction onward to recipients of the recipient's reshare" do
      retraction = SignedRetraction.build(bob, @post)
      onward_retraction = retraction.dup
      retraction.should_receive(:dup).and_return(onward_retraction)

      dis = mock
      Postzord::Dispatch.should_receive(:new).with(@resharer, onward_retraction).and_return(dis)
      dis.should_receive(:post)

      retraction.perform(@resharer)
    end
  end
end
