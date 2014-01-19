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
    it 'does not raise if the absolute_root does not exists' do
      first_reshare = FactoryGirl.create :reshare
      first_reshare.root = nil
      reshare = FactoryGirl.create :reshare, :root => first_reshare

      expect {
        PostPresenter.new(reshare).root
      }.to_not raise_error
    end

    it 'does not raise if the root does not exists' do
      reshare = FactoryGirl.create:reshare
      reshare.root = nil
      expect {
        PostPresenter.new(reshare).root
      }.to_not raise_error
    end
  end

  describe '#title' do
    context 'with posts with text' do
      context 'with a Markdown header of less than 200 characters on first line'do
        it 'returns atx style header' do
          @sm = double(:text => "## My title\n Post content...")
          @presenter.post = @sm
          @presenter.title.should == "## My title"
        end

        it 'returns setext style header' do
          @sm = double(:text => "My title \n======\n Post content...")
          @presenter.post = @sm
          @presenter.title.should == "My title \n======"
        end
      end

      context 'without a Markdown header of less than 200 characters on first line 'do
        it 'truncates post to the 20 first characters' do
          @sm = double(:text => "Very, very, very long post")
          @presenter.post = @sm
          @presenter.title.should == "Very, very, very ..."
        end
      end
    end

    context 'with posts without text' do
      it ' displays a messaage with the post class' do
        @sm = double(:text => "", :author => bob.person, :author_name => bob.person.name)
        @presenter.post = @sm
        @presenter.title.should == "A post from #{@sm.author.name}"
      end
    end
  end
end
