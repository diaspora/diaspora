require "spec_helper"

describe Diaspora::Shareable do
  describe "scopes" do
    describe ".all_public" do
      it "includes all public posts" do
        post1 = FactoryGirl.create(:status_message, author: alice.person, public: true)
        post2 = FactoryGirl.create(:status_message, author: bob.person, public: true)
        post3 = FactoryGirl.create(:status_message, author: eve.person, public: true)
        expect(Post.all_public.map(&:id)).to match_array([post1.id, post2.id, post3.id])
      end

      it "doesn't include any private posts" do
        FactoryGirl.create(:status_message, author: alice.person, public: false)
        FactoryGirl.create(:status_message, author: bob.person, public: false)
        FactoryGirl.create(:status_message, author: eve.person, public: false)
        expect(Post.all_public.map(&:id)).to eq([])
      end
    end
  end
end
