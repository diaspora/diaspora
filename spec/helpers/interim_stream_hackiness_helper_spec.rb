require 'spec_helper'

describe InterimStreamHackinessHelper do
  describe 'commenting_disabled?' do
    include Devise::TestHelpers
    before do
      sign_in alice
      def user_signed_in? 
        true
      end
    end

    it 'returns true if no user is signed in' do
      def user_signed_in? 
        false 
      end
      commenting_disabled?(double).should == true
    end

    it 'returns true if @commenting_disabled is set' do
      @commenting_disabled = true
      commenting_disabled?(double).should == true
      @commenting_disabled = false
      commenting_disabled?(double).should == false 
    end

    it 'returns @stream.can_comment? if @stream is set' do
      post = double
      @stream = double
      @stream.should_receive(:can_comment?).with(post).and_return(true)
      commenting_disabled?(post).should == false

      @stream.should_receive(:can_comment?).with(post).and_return(false)
      commenting_disabled?(post).should == true
    end
  end
end
