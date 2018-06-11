# frozen_string_literal: true

describe LinksController, type: :controller do
  describe "#resolve" do
    context "with post" do
      let(:post) { FactoryGirl.create(:status_message) }
      let(:link_text) { "#{post.author.diaspora_handle}/post/#{post.guid}" }
      subject { get :resolve, params: {q: link_query} }

      shared_examples "redirects to the post" do
        it "redirects to the post" do
          expect(subject).to redirect_to(post_url(post))
        end
      end

      context "with stripped link text" do
        let(:link_query) { link_text }
        include_examples "redirects to the post"
      end

      context "with link text starting with //" do
        let(:link_query) { "//#{link_text}" }
        include_examples "redirects to the post"
      end

      context "with link text starting with diaspora://" do
        let(:link_query) { "diaspora://#{link_text}" }
        include_examples "redirects to the post"
      end

      context "with link text starting with web+diaspora://" do
        let(:link_query) { "web+diaspora://#{link_text}" }
        include_examples "redirects to the post"
      end

      context "when post is non-fetchable" do
        let(:diaspora_id) { FactoryGirl.create(:person).diaspora_handle }
        let(:guid) { "1234567890abcdef" }
        let(:link_query) { "web+diaspora://#{diaspora_id}/post/#{guid}" }

        before do
          expect(DiasporaFederation::Federation::Fetcher)
            .to receive(:fetch_public)
            .with(diaspora_id, "post", guid)
            .and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)
        end

        it "responds 404" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when user is non-fetchable" do
        let(:diaspora_id) { "unknown@pod.tld" }
        let(:guid) { "1234567890abcdef" }
        let(:link_query) { "web+diaspora://#{diaspora_id}/post/#{guid}" }

        before do
          expect(Person)
            .to receive(:find_or_fetch_by_identifier)
            .with(diaspora_id)
            .and_return(nil)
        end

        it "responds 404" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
