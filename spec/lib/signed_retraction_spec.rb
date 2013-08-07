require 'spec_helper'

describe SignedRetraction do
  before do
    @post = FactoryGirl.create(:status_message, :author => bob.person, :public => true)
    @resharer = FactoryGirl.create(:user)
    @post.reshares << FactoryGirl.create(:reshare, :root => @post, :author => @resharer.person)
    @post.save!
  end
  describe '#perform' do
    it "dispatches the retraction onward to recipients of the recipient's reshare" do
      retraction = SignedRetraction.build(bob, @post)
      onward_retraction = retraction.dup
      retraction.should_receive(:dup).and_return(onward_retraction)

      dis = mock
      Postzord::Dispatcher.should_receive(:build).with(@resharer, onward_retraction).and_return(dis)
      dis.should_receive(:post)

      retraction.perform(@resharer)
    end
    it 'relays the retraction onward even if the post does not exist' do
      remote_post = FactoryGirl.create(:status_message, :public => true)
      bob.post(:reshare, :root_guid => remote_post.guid)
      alice.post(:reshare, :root_guid => remote_post.guid)

      remote_retraction = SignedRetraction.new.tap{|r|
        r.target_type = remote_post.type
        r.target_guid = remote_post.guid
        r.sender = remote_post.author
        r.stub!(:target_author_signature_valid?).and_return(true)
      }

      remote_retraction.dup.perform(bob)
      Post.exists?(:id => remote_post.id).should be_false

      dis = mock
      Postzord::Dispatcher.should_receive(:build){ |sender, retraction|
        sender.should == alice
        retraction.sender.should == alice.person
        dis
      }
      dis.should_receive(:post)
      remote_retraction.perform(alice)
    end
  end
end
