# frozen_string_literal: true

describe InterimStreamHackinessHelper, type: :helper do
  describe "commenting_disabled?" do
    include Devise::Test::ControllerHelpers

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
      expect(commenting_disabled?(double)).to eq(true)
    end

    it 'returns true if @commenting_disabled is set' do
      @commenting_disabled = true
      expect(commenting_disabled?(double)).to eq(true)
      @commenting_disabled = false
      expect(commenting_disabled?(double)).to eq(false) 
    end

    it 'returns @stream.can_comment? if @stream is set' do
      post = double
      @stream = double
      expect(@stream).to receive(:can_comment?).with(post).and_return(true)
      expect(commenting_disabled?(post)).to eq(false)

      expect(@stream).to receive(:can_comment?).with(post).and_return(false)
      expect(commenting_disabled?(post)).to eq(true)
    end
  end
end
