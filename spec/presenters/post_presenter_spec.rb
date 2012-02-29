require 'spec_helper'

describe PostPresenter do
  before do
    @sm = Factory(:status_message, :public => true)
    @presenter = PostPresenter.new(@sm, bob)
    @unauthenticated_presenter = PostPresenter.new(@sm)
  end

  it 'takes a post and an optional user' do
    @presenter.should_not be_nil
  end

  describe '#to_json' do
    it 'works with a user' do
      @presenter.to_json.should be_a Hash
    end

    it 'works without a user' do
      @unauthenticated_presenter.to_json.should be_a Hash
    end
  end

  describe '#user_like' do
    it 'includes the users like' do
      bob.like!(@sm)
      @presenter.user_like.should be_present
    end

    it 'is nil if the user is not authenticated' do
      @unauthenticated_presenter.user_like.should be_nil
    end
  end

  describe '#user_reshare' do
    it 'includes the users reshare' do
      bob.reshare!(@sm)
      @presenter.user_reshare.should be_present
    end

    it 'is nil if the user is not authenticated' do
      @unauthenticated_presenter.user_reshare.should be_nil
    end
  end

  describe '#user_participation' do
    it 'includes the users participation' do
      bob.participate!(@sm)
      @presenter.user_participation.should be_present
    end

    it 'is nil if the user is not authenticated' do
      @unauthenticated_presenter.user_participation.should be_nil
    end
  end

  describe '#next_post_path' do
    it 'returns a string of the users next post' do
      @presenter.should_receive(:next_post).and_return(@sm)
      @presenter.next_post_path.should ==  Rails.application.routes.url_helpers.post_path(@sm)
    end
  end

  describe '#previous_post_path' do
    it 'returns a string of the users next post' do
      @presenter.should_receive(:previous_post).and_return(@sm)
      @presenter.previous_post_path.should ==  Rails.application.routes.url_helpers.post_path(@sm)
    end
  end
  
  describe '#title' do 
    it 'includes the text if it is present' do
      @sm = stub(:text => "lalalalalalala", :author => bob.person)
      @presenter.post = @sm
      @presenter.title.should == @sm.text
    end

    context 'with posts without text' do
      it ' displays a messaage with the post class' do

        @sm = stub(:text => "", :author => bob.person)
        @presenter.post = @sm
        @presenter.title.should == "A post from #{@sm.author.name}"
      end
    end
  end
end