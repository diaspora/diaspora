describe Diaspora::Exporter::NonContactAuthors do
  describe "#query" do
    let(:user) { FactoryGirl.create(:user_with_aspect) }
    let(:post) { FactoryGirl.create(:status_message) }
    let(:instance) {
      Diaspora::Exporter::NonContactAuthors.new(Post.where(id: post.id), user)
    }

    context "without contact relationship" do
      it "includes post author to the result set" do
        expect(instance.query).to eq([post.author])
      end
    end

    context "with contact relationship" do
      before do
        user.share_with(post.author, user.aspects.first)
      end

      it "doesn't include post author to the result set" do
        expect(instance.query).to be_empty
      end
    end
  end
end
