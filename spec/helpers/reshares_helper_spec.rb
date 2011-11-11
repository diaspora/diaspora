require 'spec_helper'

describe ResharesHelper do
  include StreamHelper

  describe 'reshare_link' do
    it 'does not display a reshare for a post that does not exist' do
      reshare = Factory.build(:reshare, :root => nil)
      lambda {
        reshare_link(reshare)
      }.should_not raise_error
    end

    describe 'for a typical post' do
      before :each do
        aspect = alice.aspects.first
        @post = alice.build_post :status_message, :text => "ohai", :to => aspect.id, :public => true
        @post.save!
        alice.add_to_streams(@post, [aspect])
        alice.dispatch_post @post, :to => aspect.id
      end

      describe 'which has not been reshared' do
        before :each do
          @post.reshares_count.should == 0
        end

        it 'has "Reshare" as the English text' do
          reshare_link(@post).should =~ %r{>Reshare</a>}
        end
      end

      describe 'which has been reshared' do
        before :each do
          @reshare = Factory.create(:reshare, :root => @post)
          @post.reload
          @post.reshares_count.should == 1
        end

        it 'has "Reshare" as the English text' do
          reshare_link(@post).should =~ %r{>Reshare</a>}
        end

        it 'its reshare has "Reshare original" as the English text' do
          reshare_link(@reshare).should =~ %r{>Reshare original</a>}
        end
      end
    end
  end
end
