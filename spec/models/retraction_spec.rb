require File.dirname(__FILE__) + '/../spec_helper'

describe Retraction do
    before do
      @user = Factory.create(:user)
      @post = @user.post(:status_message, :message => "Destroy!")
      @person = Factory.create(:person)
      @user.friends << @person
      @user.save
    end
  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.id.to_s).should == true
    end
  end
  describe 'dispatching' do
    it 'should dispatch a message on delete' do
      Factory.create(:person)
      message_queue.should_receive(:add_post_request)
      @post.destroy
    end
  end
end
