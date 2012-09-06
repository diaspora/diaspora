require 'spec_helper'

describe PostPresenter do
  before do
    @sm = FactoryGirl.create(:status_message, :public => true)
    @presenter = PostPresenter.new(@sm, bob)
    @unauthenticated_presenter = PostPresenter.new(@sm)
  end

  it 'takes a post and an optional user' do
    @presenter.should_not be_nil
  end

  describe '#as_json' do
    it 'works with a user' do
      @presenter.as_json.should be_a Hash
    end

    it 'works without a user' do
      @unauthenticated_presenter.as_json.should be_a Hash
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
  
  describe '#root' do
    it 'does not raise if the root does not exists' do
      reshare = FactoryGirl.create:reshare
      reshare.root = nil
      expect {
        PostPresenter.new(reshare).root
      }.to_not raise_error
    end
  end
  
  describe '#next_post_path' do
    it 'returns a string of the users next post' do
      @presenter.next_post_path.should == "#{Rails.application.routes.url_helpers.post_path(@sm)}/next"
    end
  end

  describe '#previous_post_path' do
    it 'returns a string of the users next post' do
      @presenter.previous_post_path.should == "#{Rails.application.routes.url_helpers.post_path(@sm)}/previous"
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
