require "spec_helper"

describe Export::PostSerializer do
  let(:post) { create(:status_message_with_photo) }
  subject(:json_output) { Export::PostSerializer.new(post).to_json }

  it { is_expected.to include %("guid":"#{post.guid}") }
  it { is_expected.to include %("text":"#{post.text}") }
  it { is_expected.to include %("public":#{post.public}) }
  it { is_expected.to include %("diaspora_handle":"#{post.diaspora_handle}") }
  it { is_expected.to include %("type":"#{post.type}") }
  it { is_expected.to include %("image_url":#{post.image_url}) }
  it { is_expected.to include %("image_height":#{post.image_height}) }
  it { is_expected.to include %("image_width":#{post.image_width}) }
  it { is_expected.to include %("likes_count":#{post.likes_count}) }
  it { is_expected.to include %("comments_count":#{post.comments_count}) }
  it { is_expected.to include %("reshares_count":#{post.reshares_count}) }
  it { is_expected.to include %("created_at":"#{post.created_at.to_s[0, 4]}) }
  it { is_expected.to include %("created_at":"#{post.created_at.strftime('%FT%T.%LZ')}) }
end
