require "spec_helper"

describe Participation do
  describe 'it is relayable' do
    before do
      @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)

      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = FactoryGirl.create(:status_message, :author => @remote_raphael)
      @local_parent = @local_luke.post :status_message, :text => "foobar", :to => @local_luke.aspects.first

      @object_by_parent_author = @local_luke.participate!(@local_parent)
      @object_by_recipient = @local_leia.participate!(@local_parent)
      @dup_object_by_parent_author = @object_by_parent_author.dup

      @object_on_remote_parent = @local_luke.participate!(@remote_parent)
    end

    let(:build_object) { Participation::Generator.new(alice, @status).build }

    it_should_behave_like 'it is relayable'
  end
end
