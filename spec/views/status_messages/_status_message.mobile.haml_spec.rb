# frozen_string_literal: true

describe "status_messages/_status_message.mobile.haml" do
  it "escapes the OpenGraph metadata" do
    open_graph_cache = OpenGraphCache.new(
      url:         "<script>alert(0);</script>",
      title:       "<script>alert(0);</script>",
      image:       "https://example.org/\"><script>alert(0);</script>",
      description: "<script>alert(0);</script>"
    )
    post = FactoryBot.create(:status_message, public: true, open_graph_cache: open_graph_cache)

    render template: "status_messages/_status_message", locals: {post: post, photos: post.photos}

    expect(rendered).to_not include("<script>")
    expect(rendered).to include("&lt;script&gt;alert(0);&lt;/script&gt;")
  end
end
