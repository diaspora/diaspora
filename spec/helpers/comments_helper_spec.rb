require 'spec_helper'

describe CommentsHelper do
  describe '.new_comment_form' do
    before do
      @user = alice
      @aspect = @user.aspects.first
      @post = @user.post(:status_message, :text => "hi", :to => @aspect.id)
    end
    it 'renders a new comment form' do
      new_comment_form(@post.id, @user).should ==
        @controller.render_to_string(:partial => 'comments/new_comment',
          :locals => {:post_id => @post.id, :current_user => @user})
    end
    it 'renders it fast the second time' do
      new_comment_form(@post.id, @user)
      time = Benchmark.realtime{
        new_comment_form(@post.id, @user)
      }
      (time*1000).should < 1
    end
  end

  describe 'commenting_disabled?' do
    it 'returns true if @commenting_disabled is set' do
      @commenting_disabled = true
      commenting_disabled?(stub).should_be true
      @commenting_disabled = false
      commenting_disabled?(stub).should_be false 
    end

    it 'returns @stream.can_comment? if @stream is set' do
      post = stub
      @stream = stub
      @stream.should_receive(:can_comment?).with(post).and_return(true)
      commenting_disabled?(post).should_be true

      @stream.should_receive(:can_comment?).with(post).and_return(false)
      commenting_disabled?(post).should_be false 
    end
  end
end
