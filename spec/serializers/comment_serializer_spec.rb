require "spec_helper"

describe Export::CommentSerializer do
  let(:comment) { create(:comment) }
  subject(:json_output) { Export::CommentSerializer.new(comment).to_json }

  it { is_expected.to include %("guid":"#{comment.guid}") }
  it { is_expected.to include %("post_guid":"#{comment.post.guid}") }
  it { is_expected.to include %("text":"#{comment.text}") }
end
