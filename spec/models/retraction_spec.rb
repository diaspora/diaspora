require File.dirname(__FILE__) + '/../spec_helper'

describe Retraction do
  describe "posts" do
    before do
      @user = Factory.create(:user)
      @post = Factory.create(:status_message, :person => @user)
    end

    it 'should have a post id after serialization' do
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.id.to_s).should == true
    end

    it 'should dispatch a message on delete' do
      Factory.create(:person)
      Post.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
      @post.destroy
    end

  end
end
