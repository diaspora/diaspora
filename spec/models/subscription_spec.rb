require 'spec_helper'

describe Subscription do
  before do
    @user = create :user  # This will be the subscriber.

    @author = create :user
    @post = Post.create! author: @author.person, type: "StatusMessage", text: "Currently #coding for #diaspora."
    @tag = @post.tags.first
    
    @contact = @user.contacts.create! person_id: @author.person.id, receiving: true, sharing: true
    @aspect = @user.aspects.create! name: "Family"
    @aspect_membership = @aspect.aspect_memberships.create! contact_id: @contact.id
  end
  
  describe ".by_post" do
    subject { Subscription.by_post(@post) }
    
    describe "when the post is visible for the user" do
      before do
        @share_visibility = @post.share_visibilities.create! contact_id: @contact.id
      end
    
      describe "when the user subscribed to the post author" do
        before { @subscription = @user.subscriptions.create! channel: @post.author }
        
        it "should include the subscription of the user" do
          expect(subject).to include @user.subscriptions.first
          expect(@user.subscriptions.first).to eq @subscription
        end
      end
      
      describe "when the user subscribed to an aspect the author is member of" do
        before { @subscription = @user.subscriptions.create! channel: @aspect }
        
        it "should include the subscription of the user" do
          expect(subject).to include @user.subscriptions.first
          expect(@user.subscriptions.first).to eq @subscription
        end
      end
      
      describe "when the user subscribed to a tag of the post" do
        before { @subscription = @user.subscriptions.create! channel: @tag }
        
        it "should include the subscription of the user" do
          expect(subject).to include @user.subscriptions.first
          expect(@user.subscriptions.first).to eq @subscription
        end
      end
    end
    
    describe "when the post is not visible to the user" do
      before do
        @post.share_visibilities.destroy_all
        
        @user.subscriptions.create! channel: @post.author
        @user.subscriptions.create! channel: @aspect
        @user.subscriptions.create! channel: @tag
      end
      
      it "should not include the user's subscriptions (since the user is not allowed to see the post)" do
        expect(subject).not_to include @user.subscriptions
        expect(subject).to eq []
      end
    end
  end
end